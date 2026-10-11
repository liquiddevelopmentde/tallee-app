import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/custom_theme.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';

class DiceView extends StatefulWidget {
  /// The dice throwing menu.
  const DiceView({super.key});

  @override
  State<DiceView> createState() => _DiceViewState();
}

/// A single face of the 3D die with its value, outward normal and the
/// transform that places it on the cube.
class _Face {
  _Face({
    required this.value,
    required this.nx,
    required this.ny,
    required this.nz,
    required this.transform,
  });

  final int value;
  final double nx;
  final double ny;
  final double nz;
  final Matrix4 transform;
}

class _DiceViewState extends State<DiceView>
    with SingleTickerProviderStateMixin {
  static const double dieSize = 130;
  static const double _half = dieSize / 2;

  /// Pip positions (0-8) in a 3x3 grid, filled row by row.
  static const Map<int, List<int>> pipPositions = {
    1: [4],
    2: [0, 8],
    3: [0, 4, 8],
    4: [0, 2, 6, 8],
    5: [0, 2, 4, 6, 8],
    6: [0, 2, 3, 5, 6, 8],
  };

  /// Light direction used to shade the faces.
  static const double _lx = 0.4, _ly = -0.6, _lz = 0.7;
  static final double _lightLength = sqrt(_lx * _lx + _ly * _ly + _lz * _lz);

  late final List<_Face> faces;
  late final AnimationController controller;

  final Random random = Random();

  int result = 1;

  /// Current and target rotation angles around X (c), Y (b) and Z (a).
  double startA = 0, startB = 0, startC = 0;
  double endA = 0, endB = 0, endC = 0;

  @override
  void initState() {
    super.initState();

    faces = [
      _Face(
        value: 1,
        nx: 0,
        ny: 0,
        nz: 1,
        transform: Matrix4.identity()..translateByDouble(0.0, 0.0, _half, 1),
      ),
      _Face(
        value: 6,
        nx: 0,
        ny: 0,
        nz: -1,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, 0.0, -_half, 1)
          ..rotateY(pi),
      ),
      _Face(
        value: 2,
        nx: 1,
        ny: 0,
        nz: 0,
        transform: Matrix4.identity()
          ..translateByDouble(_half, 0.0, 0.0, 1)
          ..rotateY(pi / 2),
      ),
      _Face(
        value: 5,
        nx: -1,
        ny: 0,
        nz: 0,
        transform: Matrix4.identity()
          ..translateByDouble(-_half, 0.0, 0.0, 1)
          ..rotateY(-pi / 2),
      ),
      _Face(
        value: 3,
        nx: 0,
        ny: -1,
        nz: 0,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, -_half, 0.0, 1)
          ..rotateX(pi / 2),
      ),
      _Face(
        value: 4,
        nx: 0,
        ny: 1,
        nz: 0,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _half, 0.0, 1)
          ..rotateX(-pi / 2),
      ),
    ];

    // Start already resting on a random face.
    result = random.nextInt(6) + 1;
    final base = _baseAngles(result);
    startB = endB = base.$1;
    startC = endC = base.$2;

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.dice)),
      backgroundColor: CustomTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: dieSize,
              height: dieSize,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Ground shadow, stays in place while the die bounces.
                  Positioned(
                    bottom: -24,
                    child: Container(
                      width: dieSize * 0.66,
                      height: dieSize * 0.16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: CustomTheme.backgroundColor.withValues(
                              alpha: 0.55,
                            ),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) {
                      final t = Curves.easeOutCubic.transform(controller.value);
                      final a = _lerp(startA, endA, t);
                      final b = _lerp(startB, endB, t);
                      final c = _lerp(startC, endC, t);
                      final hop = -22 * sin(pi * controller.value);
                      final scale = 1.0 - 0.08 * sin(pi * controller.value);

                      final transform = Matrix4.identity()
                        ..setEntry(3, 2, -0.001)
                        ..rotateX(c)
                        ..rotateY(b)
                        ..rotateZ(a)
                        ..scaleByDouble(scale, scale, scale, 1);

                      return Transform.translate(
                        offset: Offset(0, hop),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: transform,
                          child: _buildCube(a, b, c),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Throw button
            BottomAnimatedButton(
              buttonText: loc.throw_dice,
              sizeRelativeToWidth: 0.6,
              onPressed: _throw,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the cube with the faces sorted back to front so the nearest face
  /// is painted last (no z-buffer, so painter's algorithm it is).
  Widget _buildCube(double a, double b, double c) {
    final rotation = Matrix4.identity()
      ..rotateX(c)
      ..rotateY(b)
      ..rotateZ(a);

    final ordered = [...faces]
      ..sort((f, g) => _normalZ(rotation, f).compareTo(_normalZ(rotation, g)));

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        for (final face in ordered)
          Transform(
            alignment: Alignment.center,
            transform: face.transform,
            child: _buildFace(face, _faceColor(rotation, face)),
          ),
      ],
    );
  }

  /// Builds a single face with its pips.
  Widget _buildFace(_Face face, Color color) {
    return Container(
      width: dieSize,
      height: dieSize,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CustomTheme.backgroundColor.withValues(alpha: 0.12),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            Expanded(
              child: Row(
                children: [
                  for (var col = 0; col < 3; col++)
                    Expanded(
                      child: pipPositions[face.value]!.contains(row * 3 + col)
                          ? const Center(child: _Pip())
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _throw() {
    setState(() {
      result = random.nextInt(6) + 1;
      startA = endA;
      startB = endB;
      startC = endC;

      final base = _baseAngles(result);
      endA = _nextAngle(startA, (random.nextInt(4)) * (pi / 2), random.nextInt(2));
      endB = _nextAngle(startB, base.$1, 1 + random.nextInt(2));
      endC = _nextAngle(startC, base.$2, 1 + random.nextInt(2));
    });
    controller.forward(from: 0);
  }

  /// Euler angles (Y, X) that bring the face with [value] to the front.
  static (double, double) _baseAngles(int value) {
    switch (value) {
      case 2:
        return (-pi / 2, 0);
      case 3:
        return (0, -pi / 2);
      case 4:
        return (0, pi / 2);
      case 5:
        return (pi / 2, 0);
      case 6:
        return (0, pi);
      default:
        return (0, 0);
    }
  }

  /// Smallest angle past [current] that is [base] plus whole turns, so each
  /// axis always spins forward by at least [extraTurns] full rotations.
  static double _nextAngle(double current, double base, int extraTurns) {
    final turns = ((current - base) / (2 * pi)).ceil();
    return base + 2 * pi * (turns + extraTurns);
  }

  static double _lerp(double from, double to, double t) =>
      from + (to - from) * t;

  static double _normalZ(Matrix4 r, _Face f) =>
      r.entry(2, 0) * f.nx + r.entry(2, 1) * f.ny + r.entry(2, 2) * f.nz;

  /// Shades a face based on how it currently faces the light.
  Color _faceColor(Matrix4 r, _Face f) {
    final nx =
        r.entry(0, 0) * f.nx + r.entry(0, 1) * f.ny + r.entry(0, 2) * f.nz;
    final ny =
        r.entry(1, 0) * f.nx + r.entry(1, 1) * f.ny + r.entry(1, 2) * f.nz;
    final nz =
        r.entry(2, 0) * f.nx + r.entry(2, 1) * f.ny + r.entry(2, 2) * f.nz;
    final dot = (nx * _lx + ny * _ly + nz * _lz) / _lightLength;
    final brightness = (0.5 + 0.5 * max(0, dot)).clamp(0.5, 1.0);
    return Color.lerp(
      CustomTheme.hintColor,
      CustomTheme.textColor,
      brightness,
    )!;
  }
}

class _Pip extends StatelessWidget {
  const _Pip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: CustomTheme.boxColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
