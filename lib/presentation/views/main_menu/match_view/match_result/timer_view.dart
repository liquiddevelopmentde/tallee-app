import 'dart:async';

import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/duration_utils.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/timer_unit_tile.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class TimerView extends StatefulWidget {
  /// Live timer dashboard for the time-based rulesets.
  ///
  /// Shows one clock per player or team with per-unit start/stop toggles and
  /// Start all / Stop all controls. Values are derived from the database, so
  /// timers keep advancing while the app is closed.
  const TimerView({super.key, required this.match, this.onTimersChanged});

  final Match match;
  final VoidCallback? onTimersChanged;

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  late final AppDatabase db;
  late final AppLifecycleListener lifecycleListener;
  Timer? ticker;

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

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
        Divider(
          height: 1,
          thickness: 1,
          color: context.talleeColors.boxBorderColor,
        ),
        const SizedBox(height: 4),

        // One row per unit
        Expanded(
          child: ListView.builder(
            itemCount: units.length,
            itemBuilder: (context, index) {
              final unit = units[index];
              final String id = unit is Team ? unit.id : (unit as Player).id;
              return TimerUnitTile(
                unit: unit,
                isTeamMatch: isTeamMatch,
                running: timerStartedAt[id] != null,
                elapsedMs: effectiveMs(id),
                onToggle: () => _toggle(id),
              );
            },
          ),
        ),
      ],
    );
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
  int effectiveMs(String id) => effectiveTimerMs(
    baseMs: baseMs[id] ?? 0,
    timerStartedAt: timerStartedAt[id],
    now: clock.now(),
  );

  Future<void> _toggle(String id) async {
    final at = clock.now();
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
    await _reload();
    widget.onTimersChanged?.call();
  }

  Future<void> _startAll() async {
    final at = clock.now();
    if (useTeams) {
      await db.teamDao.startAllTeamTimers(teamIds: unitIds, at: at);
    } else {
      await db.scoreEntryDao.startAllTimers(
        matchId: widget.match.id,
        playerIds: unitIds,
        at: at,
      );
    }
    await _reload();
    widget.onTimersChanged?.call();
  }

  Future<void> _stopAll() async {
    final at = clock.now();
    if (useTeams) {
      await db.teamDao.stopAllTeamTimers(teamIds: unitIds, at: at);
    } else {
      await db.scoreEntryDao.stopAllTimers(matchId: widget.match.id, at: at);
    }
    await _reload();
    widget.onTimersChanged?.call();
  }
}
