import 'package:flutter/material.dart';

class AppColors {
  static const Color appLightBlue = Color(0xFFD2E5FF);
  static const Color appDarkBlue = Color(0xFF83ADFF);
  static const Color appOrange = Color(0xFFFF9446);
  static const Color appPink = Color(0xFFD00070);

  static const LinearGradient blueGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFD5E7FF), Color(0xFF2A5099)],
      stops: [0.09, 1.0]);


static const LinearGradient orangeGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromARGB(255, 255, 194, 150), 
    Color.fromARGB(255, 255, 128, 38), 
  ],
  stops: [0.06, 1.0]
);

}
