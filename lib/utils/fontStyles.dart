import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Font_Styles {
  
  static double _responsiveFontSize(BuildContext context, double size) {
    double scaleFactor = MediaQuery.of(context).size.width / 500.0;
    return size * scaleFactor;
  }

  static TextStyle largeHeadingBold(BuildContext context,{Color? color}) {
    return GoogleFonts.poppins(
      fontSize: _responsiveFontSize(context, 40),
      fontWeight: FontWeight.bold,
      color: color
    );
  }

  static TextStyle mediumHeadingBold(BuildContext context,{Color? color}) {
    return GoogleFonts.poppins(
      fontSize: _responsiveFontSize(context, 35),
      fontWeight: FontWeight.bold,
      color: color
    );
  }

  static TextStyle labelHeadingLight(BuildContext context,{Color? color}) {
    return GoogleFonts.poppins(
      fontSize: _responsiveFontSize(context, 15),
      fontWeight: FontWeight.w400,
      color: color
    );
  }

  static TextStyle labelHeadingRegular(BuildContext context,{Color? color}) {
    return GoogleFonts.poppins(
      fontSize: _responsiveFontSize(context, 15),
      fontWeight: FontWeight.normal, 
      color: color
    );
  }

  static TextStyle dataTableTitle(BuildContext context, double size, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: _responsiveFontSize(context, size),
      fontWeight: FontWeight.bold, 
      color: color
    );
  }

  static TextStyle dataTableRows(BuildContext context, double size, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: _responsiveFontSize(context, size),
      fontWeight: FontWeight.normal, 
      color: color
    );
  }

  static TextStyle cardLabel(BuildContext context, {Color? color}) {
    return GoogleFonts.poppins(
      fontSize: _responsiveFontSize(context, 25),
      fontWeight: FontWeight.w600, 
      color: color
    );
  }
}

  