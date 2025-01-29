import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/models/StudentModel.dart';
import 'package:classinsight/models/TeacherModel.dart';
import 'package:classinsight/screens/teacherSide/MarksScreen.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await GetStorage.init();
  } catch (e) {
    print(e.toString());
  }

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/displayMarks',
      getPages: [
        GetPage(name: '/displayMarks', page: () => DisplayMarks()),
        GetPage(
            name: '/MarksScreen',
            page: () => MarksScreen()), // Add your MarksScreen route
      ],
    ),
  );
}

class DisplayMarksController extends GetxController {
  var studentsList = <Student>[].obs;
  var examsList = <String>[].obs;
  var subjectsListTeachers = <String>[].obs;
  // var obtainedMarks;

  var selectedSubject = ''.obs;
  late String className;
  String? schoolId;
  late Teacher teacher;

  Database_Service databaseService = Database_Service();

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

    // Use the fetchUniqueSubjects method to get the subjects taught by the teacher
    var subjectsList = await databaseService.fetchUniqueSubjects(
        schoolId!, teacher.empID, className);

    Set<String> uniqueSubjects = {};

    uniqueSubjects.addAll(subjectsList);

    subjectsListTeachers.addAll(uniqueSubjects.toList());
    if (subjectsListTeachers.isNotEmpty && selectedSubject.value.isEmpty) {
      selectedSubject.value = subjectsListTeachers.first;
    }
  }

  Future<void> fetchInitialData() async {
    if (schoolId != null) {
      await fetchSubjects(); // Correctly await the async method
      studentsList.value = await Database_Service.getStudentsOfASpecificClass(
          schoolId!, className);
      examsList.value =
          await databaseService.fetchExamStructure(schoolId!, className);
    } else {
      print('Error: schoolId is null');
    }
  }

  // Future<String> fetchTotalObtainedMarks(String studentID) async {
  //   try {
  //     DocumentSnapshot studentDoc = await FirebaseFirestore.instance
  //         .collection('Schools')
  //         .doc(schoolId!)
  //         .collection('Students')
  //         .doc(studentID)
  //         .get();

  //     if (studentDoc.exists) {
  //       Map<String, dynamic> resultMap = studentDoc['resultMap'];
  //       int totalSum = 0;

  //       var subjectResults = resultMap[selectedSubject.value] ?? {};

  //       for (var examType in examsList) {
  //         var marks = subjectResults[examType] ?? '-';
  //         if (marks is String) {
  //           RegExp regex = RegExp(r'(\d+)/(\d+)');
  //           Match? match = regex.firstMatch(marks);
  //           if (match != null) {
  //             int obtainedMarks = int.tryParse(match.group(1) ?? '0') ?? 0;
  //             totalSum += obtainedMarks;
  //           }
  //         }
  //       }

  //       return totalSum.toString();
  //     } else {
  //       return '0';
  //     }
  //   } catch (e) {
  //     print('Error fetching resultMap: $e');
  //     return '0';
  //   }
  // }

  // Future<String> fetchStudentTotalMarksSum(String studentID) async {
  //   try {
  //     DocumentSnapshot studentDoc = await FirebaseFirestore.instance
  //         .collection('Schools')
  //         .doc(schoolId!)
  //         .collection('Students')
  //         .doc(studentID)
  //         .get();

  //     if (studentDoc.exists) {
  //       Map<String, dynamic> resultMap = studentDoc['resultMap'];
  //       int totalSum = 0;

  //       // Get the results for the selected subject
  //       var subjectResults = resultMap[selectedSubject.value] ?? {};

  //       for (var examType in examsList) {
  //         var marks = subjectResults[examType] ?? '-';
  //         if (marks is String) {
  //           RegExp regex = RegExp(r'\d+/(\d+)');
  //           Match? match = regex.firstMatch(marks);
  //           if (match != null) {
  //             int totalMarks = int.tryParse(match.group(1) ?? '0') ?? 0;
  //             totalSum += totalMarks;
  //           }
  //         }
  //       }

  //       return totalSum.toString();
  //     } else {
  //       return '0';
  //     }
  //   } catch (e) {
  //     print('Error fetching resultMap: $e');
  //     return '0';
  //   }
  // }

  Future<Map<String, String>> fetchStudentResults(String studentID) async {
    if (schoolId != null) {
      Map<String, Map<String, String>>? studentResult =
          await databaseService.fetchStudentResultMap(schoolId!, studentID);
      return studentResult[selectedSubject.value] ?? {};
    } else {
      print('Error: schoolId is null');
      return {};
    }
  }

  void updateStudentResults() async {
    studentsList.refresh();
  }
}

class DisplayMarks extends StatelessWidget {
  final DisplayMarksController controller = Get.put(DisplayMarksController());

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
                        onPressed: () {
                          print(controller.className);
                          Get.toNamed('/MarksScreen', arguments: [
                            controller.schoolId,
                            controller.className,
                            controller.teacher
                          ]);
                        },
                        child: Text(
                          "Edit",
                          style: Font_Styles.labelHeadingLight(context,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.07 * screenHeight,
                  width: screenWidth,
                  margin: EdgeInsets.only(bottom: 10.0),
                  padding: EdgeInsets.only(left: 30),
                  child: Text(
                    'Subject Result',
                    style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
                Expanded(
                  child: Obx(() {
                    var examsList = controller.examsList;
                    if (examsList.isEmpty) {
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
                                for (var exam in examsList)
                                  DataColumn(
                                    label: Text(
                                      exam,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                // DataColumn(
                                //   label: Text(
                                //     'Obtained Marks',
                                //     style: TextStyle(
                                //       fontSize: 16,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                // ),
                                // DataColumn(
                                //   label: Text(
                                //     'Total Marks',
                                //     style: TextStyle(
                                //       fontSize: 16,
                                //       fontWeight: FontWeight.bold,
                                //     ),
                                //   ),
                                // ),
                              ],
                              rows: students.map((student) {
                                return DataRow(
                                  color: MaterialStateColor.resolveWith(
                                      (states) => AppColors.appOrange),
                                  cells: [
                                    DataCell(Text(student.studentRollNo)),
                                    DataCell(Text(student.name)),
                                    for (var exam in examsList)
                                      DataCell(
                                        FutureBuilder<Map<String, String>>(
                                          future:
                                              controller.fetchStudentResults(
                                                  student.studentID),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text('');
                                            } else if (snapshot.hasError) {
                                              return Text('Error');
                                            } else {
                                              final marks =
                                                  snapshot.data?[exam] ?? '-';
                                              return Text(marks);
                                            }
                                          },
                                        ),
                                      ),
                                    // DataCell(
                                    //       FutureBuilder<String>(
                                    //     future:
                                    //         controller.fetchTotalObtainedMarks(
                                    //             student.studentID),
                                    //     builder: (context, snapshot) {
                                    //       if (snapshot.connectionState ==
                                    //           ConnectionState.waiting) {
                                    //         return Text('');
                                    //       } else if (snapshot.hasError) {
                                    //         return Text('Error');
                                    //       } else {
                                    //         final totalMarksSum =
                                    //             snapshot.data ?? '0';
                                    //         return Text(totalMarksSum);
                                    //       }
                                    //     },
                                    //   ),
                                    // ),
                                    // DataCell(
                                    //   FutureBuilder<String>(
                                    //     future: controller
                                    //         .fetchStudentTotalMarksSum(
                                    //             student.studentID),
                                    //     builder: (context, snapshot) {
                                    //       if (snapshot.connectionState ==
                                    //           ConnectionState.waiting) {
                                    //         return Text('');
                                    //       } else if (snapshot.hasError) {
                                    //         return Text('Error');
                                    //       } else {
                                    //         final totalMarksSum =
                                    //             snapshot.data ?? '0';
                                    //         return Text(totalMarksSum);
                                    //       }
                                    //     },
                                    //   ),
                                    // ),
                                  ],
                                );
                              }).toList(),
                            );
                          }),
                        ),
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
