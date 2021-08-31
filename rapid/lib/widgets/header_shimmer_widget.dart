import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HeaderShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const HeaderShimmerWidget.title({
    required this.width,
    required this.height,
  }) : this.shapeBorder = const RoundedRectangleBorder();

  const HeaderShimmerWidget.circle({
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade200,
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
