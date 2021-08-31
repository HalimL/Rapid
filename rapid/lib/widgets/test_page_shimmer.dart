import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TestPageShimmer extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const TestPageShimmer.title({
    required this.width,
    required this.height,
  }) : this.shapeBorder = const RoundedRectangleBorder();

  const TestPageShimmer.circle({
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xFFEBEBF4),
      highlightColor: Color(0xFFF4F4F4),
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: shapeBorder,
        ),
      ),
    );
  }
}
