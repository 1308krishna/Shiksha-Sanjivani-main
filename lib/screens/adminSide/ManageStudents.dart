// ignore_for_file: prefer_const_constructors
import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/Widgets/CustomTextField.dart';
import 'package:classinsight/models/StudentModel.dart';
import 'package:classinsight/screens/adminSide/AdminHome.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class StudentController extends GetxController {
  var studentsList = <Student>[].obs;
  var classesList = <String>[].obs;
  var selectedClass = ''.obs;
  var selectedNewClass = ''.obs;
  var searchValid = true.obs;
  RxBool isLoading = false.obs;
  final AdminHomeController school = Get.put(AdminHomeController());

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

void fetchStudents() async {
    isLoading.value = true;
  try {
    if (selectedClass.isNotEmpty) {
      var students = await Database_Service.getStudentsOfASpecificClass(
          school.schoolId.value, selectedClass.value);
      studentsList.value = students;
    }
  } catch (e) {
    print('Error fetching students: $e');
  }
    isLoading.value = false;
}


void fetchClasses() async {
  try {
    var classes = await Database_Service.fetchAllClasses(school.schoolId.value);
    classesList.value = classes;

    if (classes.isNotEmpty && selectedClass.isEmpty) {
      selectedClass.value = classes.first;
    }
  } catch (e) {
    print('Error fetching classes: $e');
  } finally {
    fetchStudents();
  }
}


  Future<void> refreshData() async {
    isLoading.value = true;
    fetchClasses();
  }

void searchStudent(String value) async {
  if (_containsDigits(value)) {
    var students = await Database_Service.searchStudentsByRollNo(
        school.schoolId.value, selectedClass.value, value);
    studentsList.value = students;
  } else {
    var searchText = capitalize(value);
    var students = await Database_Service.searchStudentsByName(
        school.schoolId.value, selectedClass.value, searchText);
    studentsList.value = students;
  }
}


  bool _containsDigits(String value) {
    return value.contains(RegExp(r'\d'));
  }

  String capitalize(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

 void deleteStudent(BuildContext context, String studentID) async {
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Are you sure?'),
        content: Text('This will delete this student permanently'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmDelete) {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          );
        },
      );

      await Database_Service.deleteStudent(school.schoolId.value, studentID);

      Get.back();

      fetchStudents();
    } catch (e) {
      print('Error deleting student: $e');
      Get.back();  // Ensure dialog is dismissed
      Get.snackbar('Delete failed','Failed to delete student');
      
    }
  }
}

}

// ignore: must_be_immutable
class ManageStudents extends StatelessWidget {
  final StudentController studentController = Get.put(StudentController());
  TextEditingController searchController = TextEditingController();
  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Students',
          style: Font_Styles.labelHeadingLight(context),
        ),
        centerTitle: true,
        actions: <Widget>[
          Container(
            width: 48.0,
          ),
          TextButton(
            onPressed: () async {
              studentController.selectedNewClass.value =
                  await Get.toNamed("/AddStudent");

              if (studentController.selectedNewClass.value.isNotEmpty) {
                studentController.selectedClass.value =
                    studentController.selectedNewClass.value;
                studentController.refreshData();

                print(
                    'Selected Class: ${studentController.selectedNewClass.value}');
              }
            },
            child: Text(
              "Add Student",
              style: Font_Styles.labelHeadingLight(context,color: Colors.black),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: studentController.refreshData,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 10, 5),
                  child: Text(
                    'Students',
                    style: Font_Styles.mediumHeadingBold(context),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 10, 5),
                  child: Text(
                    'Class',
                    style: Font_Styles.dataTableRows(
                        context, MediaQuery.of(context).size.width * 0.04),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 15),
                  child: Obx(() {
                    return DropdownButtonFormField<String>(
                      value: studentController.selectedClass.value,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColors.appLightBlue, width: 2.0),
                        ),
                      ),
                      items: studentController.classesList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        studentController.selectedClass.value = newValue!;
                        studentController.refreshData();
                      },
                    );
                  }),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                  child: CustomTextField(
                    controller: searchController,
                    hintText: 'Search by name or roll no.',
                    labelText: 'Search Student',
                    isValid: studentController.searchValid.value,
                    onChanged: (String value) async {
                      studentController.searchStudent(value);
                    },
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Obx(() {
                  if (studentController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.appLightBlue,
                      ),
                      // child: Text('No student found in this section'),
                    );
                  } else {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false,
                        showBottomBorder: true,
                        columns: <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Roll No.',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Student Name',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Gender',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'B-Form/Challan ID',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Father Name',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Father Phone',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Father CNIC',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Fee Status',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Result',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Edit',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Delete',
                              style: Font_Styles.dataTableTitle(context,
                                  MediaQuery.of(context).size.width * 0.035),
                            ),
                          ),
                        ],
                        rows: studentController.studentsList
                            .map(
                              (student) => DataRow(
                                color: MaterialStateColor.resolveWith(
                                    (states) => AppColors.appDarkBlue),
                                cells: [
                                  DataCell(
                                    Text(
                                      student.studentRollNo,
                                      style: Font_Styles.dataTableRows(
                                          context,
                                          MediaQuery.of(context).size.width *
                                              0.035),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      student.name,
                                      style: Font_Styles.dataTableRows(
                                          context,
                                          MediaQuery.of(context).size.width *
                                              0.035),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      student.gender,
                                      style: Font_Styles.dataTableRows(
                                          context,
                                          MediaQuery.of(context).size.width *
                                              0.035),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      student.bFormChallanId,
                                      style: Font_Styles.dataTableRows(
                                          context,
                                          MediaQuery.of(context).size.width *
                                              0.035),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      student.fatherName,
                                      style: Font_Styles.dataTableRows(
                                          context,
                                          MediaQuery.of(context).size.width *
                                              0.035),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      student.fatherPhoneNo,
                                      style: Font_Styles.dataTableRows(
                                          context,
                                          MediaQuery.of(context).size.width *
                                              0.035),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      student.fatherCNIC,
                                      style: Font_Styles.dataTableRows(
                                          context,
                                          MediaQuery.of(context).size.width *
                                              0.035),
                                    ),
                                  ),
                                  DataCell(
                                    TextButton(
                                        child: Text(student.feeStatus),
                                        onPressed: () {
                                          _showFeeStatusPopup(context, student);
                                        }),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(
                                        Icons.text_snippet_outlined,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/StudentResult',
                                          arguments: Student(
                                              studentID: student.studentID,
                                              name: student.name,
                                              gender: student.gender,
                                              bFormChallanId:
                                                  student.bFormChallanId,
                                              fatherName: student.fatherName,
                                              fatherPhoneNo:
                                                  student.fatherPhoneNo,
                                              fatherCNIC: student.fatherCNIC,
                                              studentRollNo:
                                                  student.studentRollNo,
                                              classSection:
                                                  student.classSection,
                                              feeStatus: student.feeStatus,
                                              feeStartDate:
                                                  student.feeStartDate,
                                              feeEndDate: student.feeEndDate
                                              ),
                                        );
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(FontAwesomeIcons.penToSquare),
                                      onPressed: () async {
                                        print(student);
                                        var result = await Get.toNamed(
                                          '/EditStudent',
                                          arguments: Student(
                                              studentID: student.studentID,
                                              name: student.name,
                                              gender: student.gender,
                                              bFormChallanId:
                                                  student.bFormChallanId,
                                              fatherName: student.fatherName,
                                              fatherPhoneNo:
                                                  student.fatherPhoneNo,
                                              fatherCNIC: student.fatherCNIC,
                                              studentRollNo:
                                                  student.studentRollNo,
                                              classSection:
                                                  student.classSection,
                                              feeStatus: student.feeStatus,
                                              feeStartDate:
                                                  student.feeStartDate,
                                              feeEndDate: student.feeEndDate),
                                        );

                                        if (result == 'student_added') {
                                          studentController
                                              .refreshData();
                                        }
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        studentController.deleteStudent(
                                            context, student.studentID);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



void _showFeeStatusPopup(BuildContext context, Student student) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return UpdateFeeStatusDialog(student: student);
    },
  );
}
class UpdateFeeStatusDialog extends StatefulWidget {
  final Student student;

  UpdateFeeStatusDialog({required this.student});

  @override
  _UpdateFeeStatusDialogState createState() => _UpdateFeeStatusDialogState();
}

class _UpdateFeeStatusDialogState extends State<UpdateFeeStatusDialog> {
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late String feeStatus;
  late String originalStartDate;
  late String originalEndDate;

  @override
  void initState() {
    super.initState();

    feeStatus = widget.student.feeStatus;
    originalStartDate = widget.student.feeStartDate;
    originalEndDate = widget.student.feeEndDate;

    startDateController = TextEditingController(text: originalStartDate);
    endDateController = TextEditingController(text: originalEndDate);
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Fee Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: TextField(
              readOnly: true,
              controller: startDateController,
              decoration: InputDecoration(labelText: 'Start Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  startDateController.text =
                      pickedDate.toLocal().toString().split(' ')[0];
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: TextField(
              readOnly: true,
              controller: endDateController,
              decoration: InputDecoration(labelText: 'End Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  endDateController.text =
                      pickedDate.toLocal().toString().split(' ')[0];
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
            child: DropdownButtonFormField<String>(
              value: ['paid', 'unpaid'].contains(widget.student.feeStatus)
                  ? widget.student.feeStatus
                  : null,
              items: ['paid', 'unpaid'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  feeStatus = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Fee Status',
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: Text('Update'),
          onPressed: () async {
            String updatedStartDate = startDateController.text.isNotEmpty
                ? startDateController.text
                : originalStartDate;
            String updatedEndDate = endDateController.text.isNotEmpty
                ? endDateController.text
                : originalEndDate;

            widget.student.feeStatus = feeStatus;
            widget.student.feeStartDate = updatedStartDate;
            widget.student.feeEndDate = updatedEndDate;

            try {
              final AdminHomeController school = Get.find<AdminHomeController>();
              await Database_Service.updateFeeStatus(
                  school.schoolId.value,
                  widget.student.studentID,
                  feeStatus,
                  updatedStartDate,
                  updatedEndDate);

              final studentController = Get.find<StudentController>();
              studentController.refreshData();

              Get.back();
            } catch (e) {
              print('Error updating fee status: $e');
              Get.snackbar("Failed updating", "Error updating fee status");
            }
          },
        ),
      ],
    );
  }
}
