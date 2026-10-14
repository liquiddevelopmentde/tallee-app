import 'dart:math' as math;

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:tallee/core/app_color_utils.dart';
import 'package:tallee/core/enums.dart';

class ColoredCircle extends StatelessWidget {
  const ColoredCircle({
    super.key,
    this.color,
    this.hasRandomColors = false,
    this.size = 16.0,
  }) : assert(
         color == null && !hasRandomColors,
         'ColoredCircle needs a color or should be random.',
       );

  final AppColor? color;
  final bool hasRandomColors;
  final double size;

  @override
  Widget build(BuildContext context) {
    final segmentColors = [
      AppColor.red,
      AppColor.purple,
      AppColor.blue,
      AppColor.green,
      AppColor.yellow,
      AppColor.orange,
    ].map((c) => getColorFromAppColor(c)).toList();

    // Repeat first color at the end so the seam does not swallow red.
    final colors = [...segmentColors, segmentColors.first];
    final stops = List<double>.generate(
      colors.length,
      (i) => i / (colors.length - 1),
    );

    if (hasRandomColors) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            startAngle: -math.pi / 2,
            endAngle: 3 * math.pi / 2,
            colors: colors,
            stops: stops,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: getColorFromAppColor(color!),
        shape: BoxShape.circle,
      ),
    );
  }
}
