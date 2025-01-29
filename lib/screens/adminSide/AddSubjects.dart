// ignore_for_file: sized_box_for_whitespace

import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/Widgets/CustomTextField.dart';

class AddSubjectsController extends GetxController {
  RxList<String> subjects = <String>[].obs;
  TextEditingController subjectsController = TextEditingController();
  RxBool subjectsValid = true.obs;
  List<String>? classForm;

  @override
  void onInit() {
    super.onInit();
    classForm = Get.arguments;
    print(classForm);
  }

  void addSubject() {
    if (subjectsController.text.isNotEmpty) {
      subjects.add(subjectsController.text);
      subjectsController.clear();
    }
  }

  void removeSubject(String subject) {
    subjects.remove(subject);
  }
}

// ignore: must_be_immutable
class AddSubjects extends StatelessWidget {
  double addStdFontSize = 16;
  double headingFontSize = 33;

  final AddSubjectsController controller = Get.put(AddSubjectsController());

  AddSubjects({Key? key}) : super(key: key);

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
      body: SingleChildScrollView(
        child: Container(
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
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    title: Text(
                      'Add Subjects',
                      style: Font_Styles.labelHeadingLight(context),
                    ),
                    centerTitle: true,
                    actions: <Widget>[
                      Container(
                        width: 48.0,
                      ),
                      TextButton(
                        onPressed: () {
                          if (controller.subjects.isNotEmpty) {
                            Get.toNamed("/AddExamSystem", arguments: {
                              'classForm': controller.classForm,
                              'subjects': controller.subjects
                            });
                          } else {
                            Get.snackbar("Invalid Input",
                                "Check whether all the inputs are filled with correct data");
                          }
                        },
                        child: Text(
                          "Add",
                          style: Font_Styles.labelHeadingLight(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.05 * screenHeight,
                  width: screenWidth,
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Add New Subjects',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: headingFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.1,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
                            child: CustomTextField(
                              controller: controller.subjectsController,
                              hintText: 'e.g Physics',
                              labelText: 'Add Subjects',
                              isValid: true,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  controller.addSubject();
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                            child: Obx(() => Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: controller.subjects.map((subject) {
                                    return Chip(
                                      label: Text(subject),
                                      deleteIcon: const Icon(Icons.close),
                                      onDeleted: () {
                                        controller.removeSubject(subject);
                                      },
                                    );
                                  }).toList(),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
