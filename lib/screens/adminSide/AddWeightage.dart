// ignore_for_file: must_be_immutable

import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AddWeightageController extends GetxController {
  var className = ''.obs;
  RxList<String> subjects = <String>[].obs;
  RxList<String> examStructure = <String>[].obs;
  List<String>? classes;
  var weightage = <String, String>{}.obs;
  var schoolId = ''.obs; 

  @override
  void onInit() {
    super.onInit();
    className.value = Get.arguments['className'];
    classes = Get.arguments['classes'];
    subjects.assignAll(Get.arguments['subjects']);
    examStructure.assignAll(Get.arguments['examStructure']);
    schoolId.value = Get.arguments['schoolId']; 
  }

  double getTotalWeightage() {
    double total = 0.0;
    weightage.forEach((key, value) {
      total += double.tryParse(value) ?? 0.0;
    });
    return total;
  }
}

class AddWeightage extends StatelessWidget {
  final AddWeightageController controller = Get.put(AddWeightageController());
  double addStdFontSize = 16;
  double headingFontSize = 33;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 350) {
      addStdFontSize = 14;
      headingFontSize = 27;
    }
    if (screenWidth < 300) {
      addStdFontSize = 14;
      headingFontSize = 24;
    }
    if (screenWidth < 250) {
      addStdFontSize = 11;
      headingFontSize = 20;
    }
    if (screenWidth < 230) {
      addStdFontSize = 8;
      headingFontSize = 15;
    }

    return Scaffold(
      backgroundColor: AppColors.appLightBlue,
      body: Container(
          height: screenHeight,
          width: screenWidth,
          child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: screenHeight * 0.10,
                    width: screenWidth,
                    child: AppBar(
                      backgroundColor: AppColors.appLightBlue,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      title: Text(
                        'Add weightage of exams',
                        style: Font_Styles.labelHeadingLight(context),
                      ),
                      centerTitle: true,
                      actions: <Widget>[
                        Container(
                          width: 48.0,
                        ),
                        TextButton(
                          onPressed: () async {
                            double totalWeightage =
                                controller.getTotalWeightage();

                            if (totalWeightage != 100) {
                              Get.snackbar(
                                "Error",
                                "The total weightage must sum to 100.",
                                backgroundColor: Colors
                                    .red, 
                                colorText: Colors
                                    .white,
                              );

                              return;
                            }

                            Database_Service.addClass(
                              controller.classes,
                              controller.subjects,
                              controller.examStructure,
                              controller.weightage,
                              controller
                                  .schoolId.value,
                            );

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.appLightBlue),
                                  ),
                                );
                              },
                            );

                            await Future.delayed(const Duration(seconds: 3));
                            Get.offNamedUntil('/AdminHome', (route) => false);
                            Get.snackbar(
                                "Success", "Classes added successfully");
                          },
                          child: Text(
                            "Save",
                            style: Font_Styles.labelHeadingLight(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 0.07 * screenHeight,
                    width: screenWidth,
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Center(
                      child: Text(
                        'Weightage',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: headingFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.05,
                  ),
                  Expanded(
                    child: Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 4,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(30, 40, 30, 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Obx(() => Text(
                                      'Class: ${controller.className}',
                                      style: TextStyle(fontSize: 24),
                                    )),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Weightage of each exam type:',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              Obx(() => Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:
                                        controller.examStructure.map((examType) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                examType,
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  labelText: 'Enter weightage',
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  controller.weightage[examType] =
                                                      value;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      
    );
  }
}
