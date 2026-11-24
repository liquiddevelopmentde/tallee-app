import 'dart:async';

import 'package:clock/clock.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:tallee/core/duration_utils.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/views/main_menu/match_view/match_result/timer_unit_tile.dart';

class TimerView extends StatefulWidget {
  /// Live timer dashboard for the time-based rulesets.
  ///
  /// Shows one clock per player or team with per-unit start/stop toggles.
  /// Values are derived from the database, so timers keep advancing while
  /// the app is closed.
  const TimerView({
    super.key,
    required this.match,
    this.onTimersChanged,
    this.onAnyRunningChanged,
  });

  final Match match;
  final VoidCallback? onTimersChanged;

  /// Called with whether any timer is currently running, after every reload.
  final ValueChanged<bool>? onAnyRunningChanged;

  @override
  State<TimerView> createState() => TimerViewState();
}

class TimerViewState extends State<TimerView> {
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
    ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
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
    final visibleUnits = units;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: visibleUnits.length,
            itemBuilder: (context, index) {
              final unit = visibleUnits[index];
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

  /// Starts all timers if none is running, otherwise stops all running timers.
  Future<void> toggleAll() async {
    if (timerStartedAt.values.any((start) => start != null)) {
      await _stopAll();
    } else {
      await _startAll();
    }
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
    widget.onAnyRunningChanged?.call(
      timerStartedAt.values.any((start) => start != null),
    );
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
