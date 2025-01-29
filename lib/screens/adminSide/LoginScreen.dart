// ignore_for_file: prefer_const_constructors, must_be_immutable

import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/Services/Auth_Service.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> passwordController= TextEditingController().obs;
  Rx<bool> isDisabled = true.obs;


}

class LoginScreen extends StatelessWidget {
  final LoginController _controller = Get.put(LoginController());


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments = Get.arguments;
      School school = arguments['school'];
     bool adminOrNot = arguments['adminOrNot'];
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
            height: screenHeight * 0.43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.03,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login",
                    style: Font_Styles.largeHeadingBold(context),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Obx(() =>  TextField(
                    controller: _controller.emailController.value,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: "Enter your email address",
                      labelText: "Email",
                      suffixIcon: Icon(CupertinoIcons.envelope),
                      labelStyle: TextStyle(color: Colors.black),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                    ),
                  ),),
                  SizedBox(height: screenHeight * 0.02),
                  Obx(() => TextField(
                    controller: _controller.passwordController.value,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: "Enter your password",
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.black),
                      suffixIcon: GestureDetector(
                        onTap: (){
                            _controller.isDisabled.value = !_controller.isDisabled.value;
                        },
                        child: _controller.isDisabled.value?
                        Icon(CupertinoIcons.eye_fill,color: Colors.black,):
                        Icon(CupertinoIcons.eye_slash_fill,color: Colors.black,),
                        
                        ),
                        contentPadding: EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                    ),
                    obscureText: _controller.isDisabled.value ? true:false,
                  ),),
                  SizedBox(height: screenHeight * 0.03),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if(adminOrNot){

                          Auth_Service.loginAdmin(
                          _controller.emailController.value.text,
                          _controller.passwordController.value.text,
                          school
                          );
                          
                        }else{
                        Auth_Service.loginTeacher(
                          _controller.emailController.value.text,
                          _controller.passwordController.value.text,
                          school
                          );
                        }
                      },
                      child: Text(
                        "Login",
                        style: Font_Styles.labelHeadingLight(context),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(3),
                        minimumSize: Size(screenWidth * 0.3, screenHeight * 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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