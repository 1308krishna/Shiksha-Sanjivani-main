import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Google Fonts or any other initial setup
    GoogleFonts.config.allowRuntimeFetching = true; // Ensure Google Fonts are loaded
  }
}
