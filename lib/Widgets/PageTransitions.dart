import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class Go {
  static Future<T?> to<T>(dynamic page, {dynamic arguments, Transition? transition, bool? opaque}) async {
    return await Get.to<T>(page,
        arguments: arguments,
        transition: transition ?? Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
        opaque: opaque);
  }

  static Future<dynamic> off(dynamic page, {dynamic arguments, Transition? transition}) async {
    Get.off(
      page,
      arguments: arguments,
      transition: transition ?? Transition.rightToLeft,
      duration: const Duration(milliseconds: 350),
    );
  }

  static Future<dynamic> offUntil(dynamic page, {Transition? transition}) async {
    Get.offUntil(
        GetPageRoute(
          page: page,
          transition: transition ?? Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 350),
        ),
        (route) => false);
  }
  
}
