// ignore_for_file: unused_local_variable

import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/models/TeacherModel.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/Widgets/CustomTextField.dart';

class ManageTeachersController extends GetxController {
  final RxList<Teacher> teachers = <Teacher>[].obs;
  TextEditingController searchTeacherController = TextEditingController();
  bool teachersValid = true;
  late School school;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    school = Get.arguments as School;
    fetchTeachers();
  }

  @override
  void onClose() {
    searchTeacherController.dispose();
    super.onClose();
  }

  void fetchTeachers() async {
    isLoading.value = true;
    try {
      var fetchedTeachers = await Database_Service.fetchTeachers(school.schoolId);
      teachers.assignAll(fetchedTeachers);
    } catch (e) {
      print('Error fetching teachers: $e');
      Get.snackbar('Error', 'Failed to fetch teachers');
    }
    isLoading.value = false;
  }

  void searchTeacher(BuildContext context, String value) {
    if (_containsDigits(value)) {
      try {
        Database_Service.searchTeachersByEmployeeID(school.schoolId, value)
            .then((results) => teachers.assignAll(results));
      } catch (e) {
        print('Error searching for teacher: $e');
        Get.snackbar('Error', 'Failed to search for teacher');
      }
    } else {
      String searchText = capitalize(value);
      try {
        Database_Service.searchTeachersByName(school.schoolId, searchText)
            .then((results) => teachers.assignAll(results));
      } catch (e) {
        print('Error searching for teacher: $e');
        Get.snackbar('Error', 'Failed to search for teacher');
      }
    }
  }

  String capitalize(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  bool _containsDigits(String value) {
    return value.contains(RegExp(r'\d'));
  }

  void deleteTeacher(BuildContext context, String empID) async {
    bool confirmDelete = await Get.dialog(
      AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This will delete this teacher permanently'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
          barrierDismissible: false,
        );

        await Database_Service.deleteTeacher(school.schoolId, empID);

        Get.back(); // Close the loading dialog

        fetchTeachers();
      } catch (e) {
        print('Error deleting teacher: $e');
        Get.back(); // Close the loading dialog
        Get.snackbar('Error', 'Failed to delete teacher');
      }
    }
  }
}

class ManageTeachers extends StatelessWidget {
  final ManageTeachersController controller = Get.put(ManageTeachersController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double addStdFontSize = 16;
    double headingFontSize = 33;

    if (screenWidth < 350) {
      addStdFontSize = 14;
      headingFontSize = 25;
    }
    if (screenWidth < 300) {
      addStdFontSize = 14;
      headingFontSize = 23;
    }
    if (screenWidth < 250) {
      addStdFontSize = 11;
      headingFontSize = 20;
    }
    if (screenWidth < 230) {
      addStdFontSize = 8;
      headingFontSize = 17;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: screenHeight * 0.10,
                width: screenWidth,
                child: AppBar(
                  backgroundColor: Colors.white,
                  title: Text(
                    'Teachers',
                    style: Font_Styles.labelHeadingLight(context),
                  ),
                  centerTitle: true,
                  actions: <Widget>[
                    Container(
                      width: 48.0,
                    ),
                    TextButton(
                      onPressed: () async {
                        await Get.toNamed("/AddTeacher", arguments: controller.school);
                        controller.fetchTeachers();
                      },
                      child: Text(
                        "Add Teacher",
                        style: Font_Styles.labelHeadingLight(context, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 10, 5),
                child: Text(
                  'Teachers',
                  style: Font_Styles.mediumHeadingBold(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                child: CustomTextField(
                  controller: controller.searchTeacherController,
                  hintText: 'Search by name & Employee ID',
                  labelText: 'Search Teacher',
                  isValid: controller.teachersValid,
                  onChanged: (value) {
                    controller.searchTeacher(context, value);
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                        color: AppColors.appLightBlue,
                      ),
                    // child: Text(
                    //   'No Teachers found',
                    //   style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.03),
                    // ),
                  );
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: DataTable(
                      showCheckboxColumn: false,
                      showBottomBorder: true,
                      columns: <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Employee ID',
                            style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Name',
                            style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Gender',
                            style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Email',
                            style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'CNIC',
                            style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Father Name',
                            style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Classes',
                            style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                          ),
                        ),
                        DataColumn(
                          label: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Text(
                              'Subjects',
                              style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Edit',
                            style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Delete',
                            style: Font_Styles.dataTableTitle(context, MediaQuery.of(context).size.width * 0.035),
                          ),
                        ),
                      ],
                      rows: controller.teachers.map((Teacher teacher) {
                        return DataRow(
                          color: MaterialStateColor.resolveWith(
                              (states) => AppColors.appDarkBlue),
                          cells: [
                            DataCell(
                              Text(
                                teacher.empID,
                                style: Font_Styles.dataTableRows(context, MediaQuery.of(context).size.width * 0.035),
                              ),
                            ),
                            DataCell(
                              Text(
                                teacher.name,
                                style: Font_Styles.dataTableRows(context, MediaQuery.of(context).size.width * 0.035),
                              ),
                            ),
                            DataCell(
                              Text(
                                teacher.gender,
                                style: Font_Styles.dataTableRows(context, MediaQuery.of(context).size.width * 0.035),
                              ),
                            ),
                            DataCell(
                              Text(
                                teacher.email,
                                style: Font_Styles.dataTableRows(context, MediaQuery.of(context).size.width * 0.035),
                              ),
                            ),
                            DataCell(
                              Text(
                                teacher.cnic,
                                style: Font_Styles.dataTableRows(context, MediaQuery.of(context).size.width * 0.035),
                              ),
                            ),
                            DataCell(
                              Text(
                                teacher.fatherName,
                                style: Font_Styles.dataTableRows(context, MediaQuery.of(context).size.width * 0.035),
                              ),
                            ),
                            DataCell(
                              Text(
                                teacher.classes.join(', '),
                                style: Font_Styles.dataTableRows(context, MediaQuery.of(context).size.width * 0.035),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: teacher.subjects.entries.map((entry) {
                                          return Tooltip(
                                            message: entry.value.join(', '),
                                            child: Text(
                                              '${entry.key}: ${entry.value.join(', ')}',
                                              style: Font_Styles.dataTableRows(context, MediaQuery.of(context).size.width * 0.03),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              GestureDetector(
                                onTap: () async {
                                  await Get.toNamed("/EditTeacher",
                                      arguments: [teacher, controller.school]);
                                  controller.fetchTeachers();
                                },
                                child: const Icon(
                                  FontAwesomeIcons.penToSquare,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            DataCell(
                              GestureDetector(
                                onTap: () {
                                  controller.deleteTeacher(context, teacher.empID);
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
