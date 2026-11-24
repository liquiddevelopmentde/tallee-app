import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/duration_utils.dart';
import 'package:tallee/core/extensions/extensions.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/presentation/utils/name_display.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class TimerUnitTile extends StatefulWidget {
  /// One timer row with the unit name on top and its elapsed time plus a
  /// start/stop toggle below.
  const TimerUnitTile({
    super.key,
    required this.unit,
    required this.isTeamMatch,
    required this.running,
    required this.elapsedMs,
    required this.onToggle,
  });

  final dynamic unit;
  final bool isTeamMatch;
  final bool running;
  final int elapsedMs;
  final VoidCallback onToggle;

  @override
  State<TimerUnitTile> createState() => _TimerUnitTileState();
}

class _TimerUnitTileState extends State<TimerUnitTile> {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    decoration: context.standardBoxDecoration,
    child: Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Unit name
        Row(
          spacing: 5,
          children: [
            if (widget.isTeamMatch && widget.unit is Team) ...[
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: (widget.unit as Team).color.colorValue(context),
                  shape: BoxShape.circle,
                ),
              ),
            ],
            Flexible(
              child: buildUnitNameWidget(
                context,
                widget.unit,
                isTeamMatch: widget.isTeamMatch,
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
          children: [
            Expanded(
              child: Text(
                formatTimerFull(widget.elapsedMs),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: context.talleeColors.textColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            FloatingAnimatedButton(
              icon: widget.running
                  ? Icons.stop_rounded
                  : Icons.play_arrow_rounded,
              onPressed: widget.onToggle,
            ),
          ],
        ),
      ],
    ),
  );
}
