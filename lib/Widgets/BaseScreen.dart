import 'package:classinsight/utils/AppColors.dart';
import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;

  const BaseScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double circleSize;

    if (screenWidth < 600) {
      circleSize = screenWidth * 0.38;
    } else {
      circleSize = screenWidth * 0.42;
    }

    return Stack(
      children: [
        Positioned(
          top: screenHeight * 0.03,
          right: screenWidth * 0.75,
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.blueGradient,
            ),
          ),
        ),
        Positioned(
          bottom: screenHeight * 0.03,
          left: screenWidth * 0.75,
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.orangeGradient,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.2),
            child: child,
          ),
        ),
      ],
    );
  }
}
