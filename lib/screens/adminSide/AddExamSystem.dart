import 'package:classinsight/Widgets/CustomTextField.dart';
import 'package:classinsight/screens/adminSide/AdminHome.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExamSystemController extends GetxController {
  AdminHomeController school = Get.put(AdminHomeController());
  RxList<String> examStructure = <String>[].obs;
  TextEditingController examStructureController = TextEditingController();
  RxBool examValid = true.obs;
  List<String>? classes; 
  List<String>? subjects;

  @override
  void onInit() {
    super.onInit();
    Map<String, dynamic>? arguments = Get.arguments;
    classes = arguments!['classForm'];
    subjects = arguments['subjects'];

    print(classes);
    print(subjects);
  }

  void addExamStructure() {
    if (examStructureController.text.isNotEmpty) {
      examStructure.add(examStructureController.text);
      examStructureController.clear();
    }
  }

  void removeExamStructure(String exam) {
    examStructure.remove(exam);
  }
}

// ignore: must_be_immutable
class AddExamSystem extends StatelessWidget {
  AddExamSystem({Key? key}) : super(key: key);

  final AddExamSystemController controller = Get.put(AddExamSystemController());

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
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    title: Text(
                      'Add Exams',
                      style: Font_Styles.labelHeadingLight(context),
                    ),
                    centerTitle: true,
                    actions: <Widget>[
                      Container(
                        width: 48.0,
                      ),
                      TextButton(
                        onPressed: () async {
                          // Extract the class name from the first element of the classes list
                          String className = controller.classes!.first
                              .split('-')
                              .first;

                          Get.toNamed('/AddWeightage',
                              arguments: {
                                'className': className,
                                'classes': controller.classes,
                                'subjects': controller.subjects,
                                'examStructure': controller.examStructure,
                                'schoolId': controller.school.schoolId.value,
                              });
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
                  height: 0.05 * screenHeight,
                  width: screenWidth,
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Exam System',
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
                              controller: controller.examStructureController,
                              hintText: 'e.g CA/Mid/Final/Mock',
                              labelText: 'Add name of the type of exam',
                              isValid: true,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () {
                                  controller.addExamStructure();
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                            child: Obx(() => Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children:
                                      controller.examStructure.map((exam) {
                                    return Chip(
                                      label: Text(exam),
                                      deleteIcon: const Icon(Icons.close),
                                      onDeleted: () {
                                        controller.removeExamStructure(exam);
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
      
    );
  }
}
