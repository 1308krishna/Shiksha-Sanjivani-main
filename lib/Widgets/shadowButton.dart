// ignore_for_file: must_be_immutable

import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';

class ShadowButton extends StatelessWidget {
  String text;
  void Function()? onTap; 
  ShadowButton({
    required this.text,
    required this.onTap,
    super.key});

 
  @override
  Widget build(BuildContext context) {
    double screenHeight =  MediaQuery.of(context).size.height;
    double screenWidth =  MediaQuery.of(context).size.width;
    late double height;

    if (screenWidth > 350 && screenWidth <= 400) {
      height = 60;
    } else if (screenWidth > 400 && screenWidth <= 500) {
      height = 70;
    } else if (screenWidth > 500 && screenWidth <= 768) {
      height = 90;
    }else if(screenWidth>768){
      height = 100;
    } 
    else {
      height = 50; // Default height for other screen sizes
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth*0.02,
          vertical: screenHeight*0.02
        ),
        width: screenWidth*0.4,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.appLightBlue,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: Offset(5,5),
              ),
            ],
        ),
      
        child: Text(text, style: Font_Styles.labelHeadingRegular(context),),
      ),
    );
  }
}