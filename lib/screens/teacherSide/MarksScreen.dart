import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/firebase_options.dart';
import 'package:classinsight/models/StudentModel.dart';
import 'package:classinsight/models/TeacherModel.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GetStorage.init();
  } catch (e) {
    print(e.toString());
  }
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MarksScreen()));
}

class MarksScreenController extends GetxController {
  var marksTypeList = <String>[].obs;
  var studentsList = <Student>[].obs;
  final totalMarksController = TextEditingController();
  var subjectsListTeachers = <String>[].obs;
  List<dynamic>? arguments;
  String? schoolId;
  late String className;
  late Teacher teacher;

  var selectedSubject = ''.obs;
  var selectedMarksType = ''.obs;

  var totalMarksValid = true.obs;

  Database_Service databaseService = Database_Service();

  // Define a map to store TextEditingControllers for obtained marks
  var obtainedMarksControllers = <String, TextEditingController>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final List<dynamic>? arguments = Get.arguments as List<dynamic>?;

    if (arguments != null && arguments.length >= 3) {
      schoolId =
          arguments[0] as String? ?? ''; // Default to empty string if null
      className =
          arguments[1] as String? ?? ''; // Default to empty string if null
      teacher = arguments[2] as Teacher;
    } else {
      print('Error: Arguments are null or insufficient');
    }

    fetchInitialData();
    ever(selectedSubject, (_) => updateStudentResults());
  }

  Future<void> fetchSubjects() async {
    subjectsListTeachers.clear();
    print(schoolId);
    print(teacher.empID);

    var subjectsList = await databaseService.fetchUniqueSubjects(
        schoolId!, teacher.empID, className);

    Set<String> uniqueSubjects = {};

    uniqueSubjects.addAll(subjectsList);

    subjectsListTeachers.addAll(uniqueSubjects.toList());
    if (subjectsListTeachers.isNotEmpty && selectedSubject.value.isEmpty) {
      selectedSubject.value = subjectsListTeachers.first;
    }
  }

  void fetchInitialData() async {
    if (schoolId != null) {
      subjectsListTeachers.value = await databaseService.fetchUniqueSubjects(
          schoolId!, teacher.empID, className);
      studentsList.value = await Database_Service.getStudentsOfASpecificClass(
          schoolId!, className);
      marksTypeList.value =
          await databaseService.fetchExamStructure(schoolId!, className);
    } else {
      // Handle the case where schoolId is null
      print('Error: schoolId is null');
    }

    // Initialize controllers for each student
    for (var student in studentsList) {
      obtainedMarksControllers[student.studentID] = TextEditingController();
    }
  }

  Future<Map<String, String>> fetchStudentResults(String studentID) async {
    Map<String, Map<String, String>>? studentResult =
        await databaseService.fetchStudentResultMap(schoolId!, studentID);
    return studentResult[selectedSubject.value] ?? {};
  }

  void updateData() async {
    subjectsListTeachers.value = await databaseService.fetchUniqueSubjects(
        schoolId!, teacher.empID, className);
    studentsList.value = await Database_Service.getStudentsOfASpecificClass(
        schoolId!, className);
    marksTypeList.value =
        await databaseService.fetchExamStructure(schoolId!, className);
  }

  void updateStudentResults() async {
    studentsList.refresh();
  }

  String getTotalMarks() {
    return totalMarksController.text.isEmpty ? "-" : totalMarksController.text;
  }
}

class MarksScreen extends StatelessWidget {
  final MarksScreenController controller = Get.put(MarksScreenController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
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
                    backgroundColor: Colors.white,
                    title: Text(
                      'Marks',
                      style: Font_Styles.labelHeadingLight(context),
                    ),
                    centerTitle: true,
                    actions: <Widget>[
                      Container(
                        width: 48.0,
                      ),
                      TextButton(
                        onPressed: () async {
                          String? schoolId =
                              controller.schoolId; // Nullable schoolId
                          if (schoolId == null) {
                            Get.snackbar(
                              'Error',
                              'School ID is missing.',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return; // Exit the method if schoolId is null
                          }

                          String subject = controller.selectedSubject.value;
                          String examType = controller.selectedMarksType.value;
                          String totalMarks = controller.getTotalMarks();

                          // Validate if totalMarks is a number
                          if (totalMarks.isEmpty ||
                              !RegExp(r'^[0-9]+$').hasMatch(totalMarks)) {
                            // Show error message and exit if totalMarks is invalid
                            Get.snackbar(
                              'Error',
                              'Total Marks must be a valid number.',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return; // Exit the method
                          }

                          bool allValid =
                              true; // Flag to check if all obtained marks are valid

                          // Convert totalMarks to an integer for comparison
                          int totalMarksInt = int.tryParse(totalMarks) ?? 0;

                          for (var student in controller.studentsList) {
                            String studentRollNo = student.studentRollNo;
                            String studentName = student.name;
                            String obtainedMarks = controller
                                    .obtainedMarksControllers[student.studentID]
                                    ?.text ??
                                '';

                            // Validate if obtainedMarks is a number and within range
                            if (obtainedMarks.isNotEmpty) {
                              if (!RegExp(r'^[0-9]+$')
                                  .hasMatch(obtainedMarks)) {
                                obtainedMarks =
                                    '-'; // Set to '-' if obtainedMarks is not numeric
                                allValid =
                                    false; // Mark as invalid if obtainedMarks is incorrect
                              } else if ((int.tryParse(obtainedMarks) ?? -1) <
                                      0 ||
                                  (int.tryParse(obtainedMarks) ?? 0) >
                                      totalMarksInt) {
                                obtainedMarks =
                                    '-'; // Set to '-' if obtainedMarks is out of range
                                allValid =
                                    false; // Mark as invalid if obtainedMarks is out of range
                              }
                            } else {
                              obtainedMarks =
                                  '-'; // Set to '-' if obtainedMarks is empty
                            }

                            // Print the values (for debugging or logging purposes)
                            print(
                                'Roll No.: $studentRollNo, Name: $studentName, Obtained Marks: $obtainedMarks, Total Marks: $totalMarks, Subject: $subject, Exam Type: $examType');

                            // Format the marks
                            String formattedMarks =
                                '$obtainedMarks/$totalMarks';

                            // Update or add marks to the database
                            Database_Service database_service =
                                Database_Service();
                            await database_service.updateOrAddMarks(
                              schoolId,
                              student.studentID,
                              subject,
                              examType,
                              formattedMarks,
                            );
                          }

                          // Show success or error message based on validity
                          if (allValid) {
                            Get.snackbar(
                              'Success',
                              'Marks have been updated successfully.',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please enter valid marks for all students.',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Text(
                          "Save",
                          style: Font_Styles.labelHeadingLight(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 15),
                  child: Obx(() {
                    var subjectsList = controller.subjectsListTeachers;
                    if (subjectsList.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (!subjectsList
                          .contains(controller.selectedSubject.value)) {
                        controller.selectedSubject.value =
                            subjectsList.isNotEmpty ? subjectsList[0] : '';
                      }

                      return DropdownButtonFormField<String>(
                        value: controller.selectedSubject.value.isEmpty
                            ? null
                            : controller.selectedSubject.value,
                        decoration: InputDecoration(
                          labelText: "Subject",
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.appOrange, width: 2.0),
                          ),
                        ),
                        items:
                            controller.subjectsListTeachers.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedSubject.value = newValue;
                          }
                        },
                      );
                    }
                  }),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 15),
                  child: Obx(() {
                    var marksTypeList = controller.marksTypeList;
                    if (marksTypeList.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (!marksTypeList
                          .contains(controller.selectedMarksType.value)) {
                        controller.selectedMarksType.value =
                            marksTypeList.isNotEmpty ? marksTypeList[0] : '';
                      }

                      return DropdownButtonFormField<String>(
                        value: controller.selectedMarksType.value.isEmpty
                            ? null
                            : controller.selectedMarksType.value,
                        decoration: InputDecoration(
                          labelText: "Marks Type",
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.appOrange, width: 2.0),
                          ),
                        ),
                        items: marksTypeList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedMarksType.value = newValue;
                          }
                        },
                      );
                    }
                  }),
                ),
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 30, 15),
                  child: TextFormField(
                    controller: controller.totalMarksController,
                    autofocus: false,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Enter total marks',
                      labelText: 'Total Marks',
                      labelStyle: TextStyle(color: Colors.black),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10), // Adjust vertical padding as needed
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: controller.totalMarksValid.value
                              ? Colors.black
                              : Colors.red,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: AppColors.appOrange,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    var marksTypeList = controller.marksTypeList;
                    if (marksTypeList.isEmpty) {
                      return Container(
                        width: screenWidth,
                        height: 20,
                        padding: EdgeInsets.only(left: 30),
                        child: Center(
                          child: Text(
                            'No exams found for this Class',
                          ),
                        ),
                      );
                    } else {
                      return SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Obx(() {
                            var students = controller.studentsList;
                            var totalMarks = controller.getTotalMarks();
                            return DataTable(
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'Roll No.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Student Name',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Obtained Marks',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Total Marks',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              rows: students.map((student) {
                                return DataRow(
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      return AppColors.appOrange;
                                    },
                                  ),
                                  cells: [
                                    DataCell(Text(student.studentRollNo)),
                                    DataCell(Text(student.name)),
                                    DataCell(
                                      Obx(() {
                                        // Get the instance of MarksScreenController
                                        final marksController =
                                            Get.find<MarksScreenController>();

                                        // Get the TextEditingController for the current student
                                        TextEditingController controller =
                                            marksController
                                                        .obtainedMarksControllers[
                                                    student.studentID] ??
                                                TextEditingController();

                                        return TextFormField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                            hintText: 'Enter',
                                            hintStyle: TextStyle(
                                              color: const Color.fromARGB(
                                                  255,
                                                  162,
                                                  159,
                                                  159), // Light gray hint text
                                              fontWeight: FontWeight
                                                  .normal, // Ensure hint text is not bold
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical:
                                                  4, // Adjust padding if needed
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide
                                                  .none, // Remove the bottom border
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide
                                                  .none, // Remove the bottom border when focused
                                            ),
                                            errorBorder: UnderlineInputBorder(
                                              borderSide: BorderSide
                                                  .none, // Remove the bottom border on error
                                            ),
                                            focusedErrorBorder:
                                                UnderlineInputBorder(
                                              borderSide: BorderSide
                                                  .none, // Remove the bottom border on error focus
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: Colors
                                                .black, // Style input text
                                            fontWeight: FontWeight
                                                .normal, // Ensure input text is not bold
                                          ),
                                          onChanged: (value) {
                                            // Optional: Handle obtained marks input if needed
                                          },
                                        );
                                      }),
                                    ),
                                    DataCell(
                                      Text(totalMarks),
                                    ),
                                  ],
                                );
                              }).toList(),
                            );
                          }),
                        ),
                      );
                    }
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
