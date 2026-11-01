import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:tallee/core/theme/theme_context_extensions.dart';
import 'package:tallee/l10n/generated/app_localizations.dart';
import 'package:tallee/presentation/widgets/buttons/buttons.dart';
import 'package:tallee/presentation/widgets/custom_stepper.dart';

const int _minDice = 1;
const int _maxDice = 10;

/// Pip positions (0-8) in a 3x3 grid, filled row by row.
const Map<int, List<int>> _pipPositions = {
  1: [4],
  2: [0, 8],
  3: [0, 4, 8],
  4: [0, 2, 6, 8],
  5: [0, 2, 4, 6, 8],
  6: [0, 2, 3, 5, 6, 8],
};

/// Light direction used to shade the dice faces.
const double _lx = 0.4, _ly = -0.6, _lz = 0.7;
final double _lightLength = sqrt(_lx * _lx + _ly * _ly + _lz * _lz);

class DiceView extends StatefulWidget {
  /// The dice throwing menu.
  const DiceView({super.key});

  @override
  State<DiceView> createState() => _DiceViewState();
}

/// A single face of a die with its value, outward normal and the transform
/// that places it on the cube.
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

/// Mutable state of a single die: its value and current/target rotation angles.
class _DieState {
  _DieState(this.value);

  int value;
  double startA = 0, startB = 0, startC = 0;
  double endA = 0, endB = 0, endC = 0;
}

class _DiceViewState extends State<DiceView>
    with SingleTickerProviderStateMixin {
  final Random random = Random();

  late final AnimationController controller;
  final List<_DieState> dice = [];

  int diceCount = 1;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    dice.add(_createDie());
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
      backgroundColor: context.talleeColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      for (final die in dice)
                        _Die(size: _dieSize, state: die, animation: controller),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Text(
                  loc.dice,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomStepper(
                  value: diceCount,
                  minValue: _minDice,
                  maxValue: _maxDice,
                  onChanged: _setDiceCount,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: BottomAnimatedButton(
                buttonText: loc.throw_dice,
                sizeRelativeToWidth: 0.6,
                onPressed: _throw,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The die size, smaller the more dice are shown.
  double get _dieSize {
    if (diceCount == 1) return 140;
    if (diceCount <= 4) return 100;
    return 74;
  }

  /// Creates a die resting on a random face.
  _DieState _createDie() {
    final die = _DieState(random.nextInt(6) + 1);
    final base = _baseAngles(die.value);
    die.startB = die.endB = base.$1;
    die.startC = die.endC = base.$2;
    return die;
  }

  void _setDiceCount(int count) {
    setState(() {
      diceCount = count;
      while (dice.length < count) {
        dice.add(_createDie());
      }
      while (dice.length > count) {
        dice.removeLast();
      }
    });
  }

  void _throw() {
    setState(() {
      for (final die in dice) {
        die.value = random.nextInt(6) + 1;
        die.startA = die.endA;
        die.startB = die.endB;
        die.startC = die.endC;

        final base = _baseAngles(die.value);
        die.endA = _nextAngle(
          die.startA,
          random.nextInt(4) * (pi / 2),
          random.nextInt(2),
        );
        die.endB = _nextAngle(die.startB, base.$1, 1 + random.nextInt(2));
        die.endC = _nextAngle(die.startC, base.$2, 1 + random.nextInt(2));
      }
    });
    controller.forward(from: 0);
  }
}

/// A single tumbling 3D die.
class _Die extends StatelessWidget {
  const _Die({
    required this.size,
    required this.state,
    required this.animation,
  });

  final double size;
  final _DieState state;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final faces = _buildFaces(size / 2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ground shadow, stays in place while the die bounces.
          Positioned(
            bottom: -size * 0.12,
            child: Container(
              width: size * 0.66,
              height: size * 0.14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: context.talleeColors.backgroundColor.withValues(
                      alpha: 0.55,
                    ),
                    blurRadius: size * 0.18,
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(animation.value);
              final a = _lerp(state.startA, state.endA, t);
              final b = _lerp(state.startB, state.endB, t);
              final c = _lerp(state.startC, state.endC, t);
              final hop = -size * 0.16 * sin(pi * animation.value);
              final scale = 1.0 - 0.08 * sin(pi * animation.value);

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
                  child: _buildCube(faces, size, a, b, c, context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The six faces of the die for a cube of the given half extent.
List<_Face> _buildFaces(double half) => [
  _Face(
    value: 1,
    nx: 0,
    ny: 0,
    nz: 1,
    transform: Matrix4.identity()..translateByDouble(0.0, 0.0, half, 1),
  ),
  _Face(
    value: 6,
    nx: 0,
    ny: 0,
    nz: -1,
    transform: Matrix4.identity()
      ..translateByDouble(0.0, 0.0, -half, 1)
      ..rotateY(pi),
  ),
  _Face(
    value: 2,
    nx: 1,
    ny: 0,
    nz: 0,
    transform: Matrix4.identity()
      ..translateByDouble(half, 0.0, 0.0, 1)
      ..rotateY(pi / 2),
  ),
  _Face(
    value: 5,
    nx: -1,
    ny: 0,
    nz: 0,
    transform: Matrix4.identity()
      ..translateByDouble(-half, 0.0, 0.0, 1)
      ..rotateY(-pi / 2),
  ),
  _Face(
    value: 3,
    nx: 0,
    ny: -1,
    nz: 0,
    transform: Matrix4.identity()
      ..translateByDouble(0.0, -half, 0.0, 1)
      ..rotateX(pi / 2),
  ),
  _Face(
    value: 4,
    nx: 0,
    ny: 1,
    nz: 0,
    transform: Matrix4.identity()
      ..translateByDouble(0.0, half, 0.0, 1)
      ..rotateX(-pi / 2),
  ),
];

/// Builds the cube with the faces sorted back to front so the nearest face
/// is painted last (no z-buffer, so painter's algorithm it is).
Widget _buildCube(
  List<_Face> faces,
  double size,
  double a,
  double b,
  double c,
  BuildContext context,
) {
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
          child: _buildFace(
            face,
            _faceColor(rotation, face, context),
            size,
            context,
          ),
        ),
    ],
  );
}

/// Builds a single face with its pips.
Widget _buildFace(_Face face, Color color, double size, BuildContext context) {
  return Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(size * 0.12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(size * 0.08),
      border: Border.all(
        color: context.talleeColors.backgroundColor.withValues(alpha: 0.12),
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
                    child: _pipPositions[face.value]!.contains(row * 3 + col)
                        ? Center(child: _Pip(size: size * 0.14))
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

double _normalZ(Matrix4 r, _Face f) =>
    r.entry(2, 0) * f.nx + r.entry(2, 1) * f.ny + r.entry(2, 2) * f.nz;

/// Shades a face based on how it currently faces the light.
Color _faceColor(Matrix4 r, _Face f, BuildContext context) {
  final nx = r.entry(0, 0) * f.nx + r.entry(0, 1) * f.ny + r.entry(0, 2) * f.nz;
  final ny = r.entry(1, 0) * f.nx + r.entry(1, 1) * f.ny + r.entry(1, 2) * f.nz;
  final nz = r.entry(2, 0) * f.nx + r.entry(2, 1) * f.ny + r.entry(2, 2) * f.nz;
  final dot = (nx * _lx + ny * _ly + nz * _lz) / _lightLength;
  final brightness = (0.5 + 0.5 * max(0, dot)).clamp(0.5, 1.0);
  return Color.lerp(
    context.talleeColors.hintColor,
    context.talleeColors.textColor,
    brightness,
  )!;
}

/// Euler angles (Y, X) that bring the face with [value] to the front.
(double, double) _baseAngles(int value) {
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
double _nextAngle(double current, double base, int extraTurns) {
  final turns = ((current - base) / (2 * pi)).ceil();
  return base + 2 * pi * (turns + extraTurns);
}

double _lerp(double from, double to, double t) => from + (to - from) * t;

class _Pip extends StatelessWidget {
  const _Pip({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.talleeColors.boxColor,
        shape: BoxShape.circle,
      ),
    );
  }
}
