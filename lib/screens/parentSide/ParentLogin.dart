// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/Services/Auth_Service.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentLoginController extends GetxController {
  Rx<TextEditingController> challanIDbFormController = TextEditingController().obs;
  Rx<bool> isDisabled = true.obs;
  late School school;

  @override
  void onInit() {
    school = Get.arguments as School;
    super.onInit();
  }
}

class ParentLoginScreen extends StatelessWidget {
  final ParentLoginController _controller = Get.put(ParentLoginController());


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.appLightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.appLightBlue,
      ),
      body: Center(
        child: SafeArea(
          child: Container(
            width: screenWidth * 0.9,
            height: screenHeight * 0.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.035,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter your Challan ID/B-form number",
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Obx(() =>  TextFormField(
                    controller: _controller.challanIDbFormController.value,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {

                          if (_controller.challanIDbFormController.value.text.isNotEmpty) {
                              Auth_Service.loginParent(_controller.school, _controller.challanIDbFormController.value.text);

                          } else {
                          }
                        },
                        icon: Icon(
                          CupertinoIcons.arrow_right,
                          color: Colors.black,
                        ),
                        color: Colors.black,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: "Challan/Bform number",
                      labelText: "Challan/Bform",
                      labelStyle: TextStyle(color: Colors.black),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                    ),
                    
                  ),
                  ),
                                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
