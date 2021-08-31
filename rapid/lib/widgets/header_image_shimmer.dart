import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HeaderImageShimmerWidget extends StatelessWidget {
  final double width;
  final double height;

  const HeaderImageShimmerWidget.header({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(0xFFEBEBF4),
      highlightColor: Color(0xFFF4F4F4),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
      ),
    );
  }
}
