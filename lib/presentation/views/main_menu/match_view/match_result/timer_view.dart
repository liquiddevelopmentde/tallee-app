import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/common.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

/// Live timer dashboard for the time-based rulesets.
///
/// Shows one running clock per player (or team), with per-unit start/stop
/// toggles and Start all / Stop all controls.
///
/// The current value is derived from the database:
///   effective_ms = accumulated score + (now - timerStartedAt)
/// so timers keep advancing while the app is closed. State is always re-read
/// from the DB (never taken from the [match] snapshot) and refreshed once per
/// second and on app resume.
class TimerView extends StatefulWidget {
  const TimerView({
    super.key,
    required this.match,
    this.onTimersChanged,
    this.onMatchReopened,
  });

  final Match match;

  /// Called after any start/stop so the parent can refresh its own state.
  final VoidCallback? onTimersChanged;

  /// Called when starting a timer re-opened a previously finished match so the
  /// parent can refresh the match list/detail.
  final VoidCallback? onMatchReopened;

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  late final AppDatabase db;
  late final AppLifecycleListener lifecycleListener;
  Timer? ticker;

  /// Whether the match was finished when this view opened. Cleared once a timer
  /// start re-opens the match.
  late bool _matchEnded;

  /// Accumulated ms per unit while stopped (the persisted [ScoreEntry.score] /
  /// [Team.score] value).
  final Map<String, int> baseMs = {};

  /// Wall-clock start per unit; null means the timer is stopped.
  final Map<String, DateTime?> timerStartedAt = {};

  bool get useTeams => widget.match.useTeamLogic;

  bool get isTeamMatch => widget.match.isTeamMatch;

  List<Player> get players =>
      List<Player>.from(widget.match.players)
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

  List<Team> get teams =>
      List<Team>.from(widget.match.teams ?? [])
        ..sort((a, b) => a.name.compareIgnoringCaseTo(b.name));

  List<dynamic> get units => useTeams ? teams : players;

  List<String> get unitIds => useTeams
      ? teams.map((team) => team.id).toList()
      : players.map((player) => player.id).toList();

  @override
  void initState() {
    super.initState();
    db = context.read<AppDatabase>();
    _matchEnded = widget.match.endedAt != null;
    lifecycleListener = AppLifecycleListener(onResume: _reload);
    _reload();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    ticker?.cancel();
    lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final data = useTeams
        ? await db.teamDao.getTeamTimers(teamIds: unitIds)
        : await db.scoreEntryDao.getTimers(matchId: widget.match.id);
    if (!mounted) return;
    setState(() {
      baseMs
        ..clear()
        ..addAll(data.map((id, value) => MapEntry(id, value.elapsedMs)));
      timerStartedAt
        ..clear()
        ..addAll(data.map((id, value) => MapEntry(id, value.timerStartedAt)));
    });
  }

  /// Returns the effective elapsed ms for [id] at the current instant.
  int effectiveMs(String id) {
    final base = baseMs[id] ?? 0;
    final start = timerStartedAt[id];
    if (start == null) return base;
    return base + DateTime.now().difference(start).inMilliseconds;
  }

  /// Re-opens the match if it was already finished and a timer just started.
  Future<void> _reopenIfNeeded() async {
    if (!_matchEnded) return;
    await db.matchDao.removeMatchEndedAt(matchId: widget.match.id);
    _matchEnded = false;
    widget.onMatchReopened?.call();
  }

  Future<void> _toggle(String id) async {
    final at = DateTime.now();
    final starting = timerStartedAt[id] == null;
    if (useTeams) {
      if (starting) {
        await db.teamDao.startTeamTimer(teamId: id, at: at);
      } else {
        await db.teamDao.stopTeamTimer(teamId: id, at: at);
      }
    } else {
      if (starting) {
        await db.scoreEntryDao.startTimer(
          playerId: id,
          matchId: widget.match.id,
          at: at,
        );
      } else {
        await db.scoreEntryDao.stopTimer(
          playerId: id,
          matchId: widget.match.id,
          at: at,
        );
      }
    }
    if (starting) await _reopenIfNeeded();
    await _reload();
    widget.onTimersChanged?.call();
  }

  Future<void> _startAll() async {
    final at = DateTime.now();
    if (useTeams) {
      await db.teamDao.startAllTeamTimers(teamIds: unitIds, at: at);
    } else {
      await db.scoreEntryDao.startAllTimers(
        matchId: widget.match.id,
        playerIds: unitIds,
        at: at,
      );
    }
    await _reopenIfNeeded();
    await _reload();
    widget.onTimersChanged?.call();
  }

  Future<void> _stopAll() async {
    final at = DateTime.now();
    if (useTeams) {
      await db.teamDao.stopAllTeamTimers(teamIds: unitIds, at: at);
    } else {
      await db.scoreEntryDao.stopAllTimers(matchId: widget.match.id, at: at);
    }
    await _reload();
    widget.onTimersChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final visibleUnits = units;

    return Column(
      children: [
        // Global controls
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingAnimatedButton(
                icon: Icons.play_arrow_rounded,
                text: loc.start_all,
                onPressed: _startAll,
              ),
              FloatingAnimatedButton(
                icon: Icons.stop_rounded,
                text: loc.stop_all,
                onPressed: _stopAll,
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: CustomTheme.boxBorderColor,
        ),
        const SizedBox(height: 4),

        // One row per unit
        Expanded(
          child: ListView.builder(
            itemCount: visibleUnits.length,
            itemBuilder: (context, index) =>
                _buildUnitTile(context, loc, visibleUnits[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitTile(
    BuildContext context,
    AppLocalizations loc,
    dynamic unit,
  ) {
    final String id = unit is Team ? unit.id : (unit as Player).id;
    final bool running = timerStartedAt[id] != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: CustomTheme.standardBoxDecoration,
      child: Column(
        spacing: 4,
        children: [
          // Colored unit name
          Row(
            spacing: 5,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isTeamMatch && unit is Team) ...[
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: getColorFromAppColor(unit.color),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              Flexible(
                child: buildUnitNameWidget(
                  unit,
                  isTeamMatch: isTeamMatch,
                  rowAlignment: MainAxisAlignment.center,
                  mainStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          // Time + toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 52),
              Expanded(
                child: Text(
                  formatTimer(effectiveMs(id)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                    color: CustomTheme.textColor,
                  ),
                ),
              ),
              Tooltip(
                message: running ? loc.stop_timer : loc.start_timer,
                child: FloatingAnimatedButton(
                  icon: running ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  onPressed: () => _toggle(id),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
