// ignore_for_file: invalid_use_of_protected_member

import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/screens/adminSide/AdminHome.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:classinsight/Widgets/CustomTextField.dart';
import 'package:classinsight/utils/AppColors.dart';

class AddClassSectionsController extends GetxController {
  RxnInt selectedSections = RxnInt();
  RxString selectedDelete = ''.obs;
  RxBool textShow = false.obs;
  var textFieldValue = ''.obs;
  RxList<bool> isValidList = <bool>[].obs;
  TextEditingController gradeName = TextEditingController();
  RxList<TextEditingController> sectionControllers = <TextEditingController>[].obs;
  RxBool addClass = true.obs;
  RxList<String> sections = <String>[].obs;
  AdminHomeController school = Get.put(AdminHomeController());

  @override
  void onInit() {
    super.onInit();
    fetchSections();
  }

  Future<void> deleteSection(String section, BuildContext context) async {
    try {

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

      await Database_Service.deleteClassByName(school.schoolName.value,section);
      sections.remove(section);
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
      Get.snackbar("Deleted succesfully",'Class ${section} deleted succesfully');
      fetchSections(); // Refresh the sections list after deletion
      update();
    } catch (e) {
      print("Error deleting section: $e");
    }
  }

  void fetchSections() async {
    sections.value = await Database_Service.fetchClasses(school.schoolId.value);
    print(sections.value);
    update();
  }

  void updateSections(int sections) {
    isValidList.clear();
    sectionControllers.clear();
    for (int i = 0; i < sections; i++) {
      sectionControllers.add(TextEditingController());
      isValidList.add(true);
    }
  }

  bool validateFields() {
    bool isValid = true;
    for (int i = 0; i < sectionControllers.length; i++) {
      if (sectionControllers[i].text.trim().isEmpty) {
        isValid = false;
        isValidList[i] = false;
      } else {
        isValidList[i] = true;
      }
    }
    update();
    return isValid;
  }

  List<String> collectFormValues() {
    List<String> formData = [];

    String gradeNameValue = gradeName.text.trim();
    if (gradeNameValue.isNotEmpty && selectedSections.value != null) {
      for (int i = 0; i < selectedSections.value!; i++) {
        String sectionValue = sectionControllers[i].text.trim();
        if (sectionValue.isNotEmpty) {
          formData.add('$gradeNameValue-$sectionValue');
        }
      }
    }

    return formData;
  }
}

class AddClassSections extends StatelessWidget {
  final AddClassSectionsController controller = Get.put(AddClassSectionsController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

      controller.gradeName.addListener(() {
      controller.textFieldValue.value = controller.gradeName.text;
    });

    return Scaffold(
      backgroundColor: AppColors.appLightBlue,
      body:  Container(
          height: screenHeight,
          width: screenWidth,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: screenHeight * 0.20,
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
                      'Classes and Sections',
                      style: Font_Styles.labelHeadingLight(context),
                    ),
                    centerTitle: true,
                    actions: <Widget>[
                      Container(
                        width: 48.0, // Adjust as needed
                      ),
                      Obx(() {
                        if (controller.addClass.value) {
                          return controller.textFieldValue.isNotEmpty ? TextButton(
                            onPressed: () {
                              if (controller.validateFields()) {
                                List<String> formData = controller.collectFormValues();
                                print(formData);
                                Get.toNamed("/AddSubjects", arguments: formData);
                              } else {
                                Get.snackbar("Invalid Input", "Check whether all the inputs are filled with correct data");
                              }
                            },
                            child: Text(
                              "Next",
                              style: Font_Styles.labelHeadingLight(context,color: Colors.black),
                            ),
                          ):Container();
                        } else {
                          return TextButton(
                            onPressed: () {
                              if (controller.sections.isNotEmpty) {
                                controller.deleteSection(controller.selectedDelete.value,context);
                                controller.selectedDelete.value = '';
                              } else {
                                Get.snackbar("Invalid Input", "No sections available to delete");
                              }
                            },
                            child: Text(
                              "Delete",
                              style: Font_Styles.labelHeadingLight(context),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    height: 0.05 * screenHeight,
                    width: screenWidth * 0.8,
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: Obx(
                      () => Container(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.055,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.addClass.value ? "Add Class and Section" : "Delete a Section",
                              onChanged: (item) {
                                controller.addClass.value = item == "Add Class and Section";
                              },
                              items: [
                                DropdownMenuItem<String>(
                                  value: "Add Class and Section",
                                  child: Text("Add Class and Section"),
                                ),
                                DropdownMenuItem<String>(
                                  value: "Delete a Section",
                                  child: Text("Delete a Section"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            if (controller.addClass.value) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
                                    child: CustomTextField(
                                      controller: controller.gradeName,
                                      hintText: 'Enter the Grade/Class Name',
                                      labelText: 'Class Name',
                                      isValid: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(30, 0, 40, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            'Number of Sections',
                                            style: Font_Styles.labelHeadingLight(context),
                                          ),
                                        ),
                                        Obx(
                                          () => Container(
                                            width: screenWidth * 0.3,
                                            height: screenHeight * 0.045,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black),
                                              borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<int>(
                                                  hint: const Text('Select'),
                                                  value: controller.selectedSections.value,
                                                  items: List.generate(5, (index) => index + 1)
                                                      .map((e) => DropdownMenuItem<int>(
                                                            value: e,
                                                            child: Text(e.toString()),
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) {
                                                    controller.textShow.value = true;
                                                    if (value != null) {
                                                      controller.selectedSections.value = value;
                                                      controller.updateSections(value);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Obx(
                                    () => controller.textShow.value
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                            child: Text("Add name of sections (e.g: alphabets or colors)"),
                                          )
                                        : Center(
                                            child: Text("No Sections added", style: Font_Styles.labelHeadingLight(context)),
                                          ),
                                  ),
                                  Obx(
                                    () => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                      child: Column(
                                        children: controller.selectedSections.value != null
                                            ? List.generate(
                                                controller.selectedSections.value!,
                                                (index) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 20.0),
                                                  child: CustomTextField(
                                                    controller: controller.sectionControllers[index],
                                                    hintText: 'Enter Section Name ${index + 1}',
                                                    labelText: 'Section Name ${index + 1}',
                                                   
                                                isValid: true,
                                              ),
                                            ),
                                          )
                                        : [],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Delete a Section",
                                    style: Font_Styles.labelHeadingLight(context),
                                  ),
                                  SizedBox(height: 20),
                                  Column(
                                    children: [
                                      Container(
                                        width: screenWidth * 0.8,
                                        height: screenHeight * 0.055,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Obx(()=>
                                            DropdownButtonHideUnderline(
                                              child: 
                                            DropdownButton<String>(
                                            value: controller.selectedDelete.value.isNotEmpty ? controller.selectedDelete.value : controller.sections.first,
                                            onChanged: (item) {
                                              controller.selectedDelete.value = item!;
                                            },
                                            
                                            items: controller.sections.map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20,),

                                      Text(
                                        "Make sure you have no teachers and students assigned for this class section",
                                        softWrap: true,
                                        style: TextStyle(color: Colors.red),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
  ));
}
}