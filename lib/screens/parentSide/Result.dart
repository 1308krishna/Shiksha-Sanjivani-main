import 'package:classinsight/firebase_options.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:get/get.dart';
import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/models/StudentModel.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ResultController extends GetxController {
  var student = Student(
    name: '',
    gender: '',
    bFormChallanId: '',
    fatherName: '',
    fatherPhoneNo: '',
    fatherCNIC: '',
    studentID: '',
    classSection: '',
    feeStatus: '',
    feeStartDate: '',
    feeEndDate: '',
    studentRollNo: '',
  ).obs;
  var examsList = <String>[].obs;
  var subjectsList = <String>[].obs;
  var resultMap = <String, Map<String, String>>{}.obs;
  var weightageMap = <String, String>{}.obs;
  var isLoading = true.obs;
  final String schoolId;

  ResultController(this.schoolId);

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void setStudent(Student newStudent) {
    student.value = newStudent;
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      examsList.value = await Database_Service()
          .fetchExamStructure(schoolId, student.value.classSection);
      subjectsList.value = await Database_Service.fetchSubjects(
          schoolId, student.value.classSection);
      resultMap.value = await Database_Service()
          .fetchStudentResultMap(schoolId, student.value.studentID);
          // Fetch weightage for the class
      weightageMap.value = await Database_Service()
          .fetchWeightage(schoolId, student.value.classSection);
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, String> calculateGrades() {
    Map<String, String> grades = {};

    for (var subject in subjectsList) {
      double subjectPercentage = 0.0;
      var subjectResults = resultMap[subject] ?? {};
      double totalWeightage = 0.0;
      bool allExamsEntered = true;

      for (var exam in examsList) {
        var score = subjectResults[exam];
        var weightage = weightageMap[exam];

        if (score == null || weightage == null || score == '-') {
          allExamsEntered = false; // Missing exam data
          break; // No need to continue if any exam data is missing
        }

        var parts = score.split('/');
        if (parts.length == 2) {
          // Ensure there are exactly two parts
          double obtainedMarks = double.tryParse(parts[0]) ?? 0.0;
          double totalMarks = double.tryParse(parts[1]) ?? 0.0;

          if (totalMarks > 0) {
            double examPercentage = (obtainedMarks / totalMarks) * 100;
            double examWeightage = double.tryParse(weightage) ?? 0.0;
            subjectPercentage += (examPercentage * examWeightage) / 100;
            totalWeightage += examWeightage;
          }
        }
      }

      if (allExamsEntered) {
        if (totalWeightage > 0) {
          subjectPercentage = (subjectPercentage / totalWeightage) * 100;
          grades[subject] = _mapPercentageToGrade(subjectPercentage);
        } else {
          grades[subject] = '-'; // If no weightage, return '-'
        }
      } else {
        grades[subject] = '-'; // Return '-' if not all exams are entered
      }
    }

    return grades;
  }

  String _mapPercentageToGrade(double percentage) {
    if (percentage >= 95) return 'A+';
    if (percentage >= 90) return 'A';
    if (percentage >= 85) return 'A-';
    if (percentage >= 80) return 'B+';
    if (percentage >= 75) return 'B';
    if (percentage >= 70) return 'B-';
    if (percentage >= 65) return 'C+';
    if (percentage >= 60) return 'C';
    if (percentage >= 55) return 'C-';
    if (percentage >= 50) return 'D+';
    if (percentage >= 45) return 'D';
    if (percentage >= 40) return 'D-';
    return 'F';
  }

  // Future<String> fetchTotalObtainedMarks(
  //     String studentID, String subject) async {
  //   try {
  //     DocumentSnapshot studentDoc = await FirebaseFirestore.instance
  //         .collection('Schools')
  //         .doc(schoolId)
  //         .collection('Students')
  //         .doc(studentID)
  //         .get();

  //     if (studentDoc.exists) {
  //       Map<String, dynamic> resultMap = studentDoc['resultMap'];
  //       int totalSum = 0;

  //       var subjectResults = resultMap[subject] ?? {};

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

  // Future<String> fetchStudentTotalMarksSum(
  //     String studentID, String subject) async {
  //   try {
  //     DocumentSnapshot studentDoc = await FirebaseFirestore.instance
  //         .collection('Schools')
  //         .doc(schoolId)
  //         .collection('Students')
  //         .doc(studentID)
  //         .get();

  //     if (studentDoc.exists) {
  //       Map<String, dynamic> resultMap = studentDoc['resultMap'];
  //       int totalSum = 0;

  //       var subjectResults = resultMap[subject] ?? {};

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
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Result(),
    );
  }
}

class Result extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>;
    final Student student = arguments['student'];
    final String schoolId = arguments['schoolId'];

    final ResultController controller = Get.put(ResultController(schoolId));
    controller.setStudent(student);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Result", style: Font_Styles.labelHeadingRegular(context)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;
        Map<String, String> subjectGrades = controller.calculateGrades();

        double resultFontSize = screenWidth < 350
            ? (screenWidth < 300 ? (screenWidth < 250 ? 11 : 14) : 14)
            : 16;
        double headingFontSize = screenWidth < 350
            ? (screenWidth < 300 ? (screenWidth < 250 ? 20 : 23) : 25)
            : 33;

        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.appOrange),
            ),
          );
        } else {
          // Debug prints to check data consistency
          print('Exams List: ${controller.examsList}');
          print('Subjects List: ${controller.subjectsList}');
          print('Result Map: ${controller.resultMap}');
          print('Weightage Map: ${controller.weightageMap}');

          return SingleChildScrollView(
            child: Container(
              height: screenHeight,
              width: screenWidth,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      height: 0.05 * screenHeight,
                      width: screenWidth,
                      margin: EdgeInsets.only(bottom: 10.0),
                      padding: EdgeInsets.only(left: 30),
                      child: Text(
                        controller.student.value.name,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: headingFontSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(() {
                        List<String> exams = controller.examsList;
                        List<String> subjects = controller.subjectsList;
                        Map<String, Map<String, String>> resultMap =
                            controller.resultMap;

                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Subjects',
                                  style: TextStyle(
                                    fontSize: resultFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...exams.map((exam) => DataColumn(
                                    label: Text(
                                      exam,
                                      style: TextStyle(
                                        fontSize: resultFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )),
                              // DataColumn(
                              //   label: Text(
                              //     'Obtained Marks',
                              //     style: TextStyle(
                              //       fontSize: resultFontSize,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                              // DataColumn(
                              //   label: Text(
                              //     'Total Marks',
                              //     style: TextStyle(
                              //       fontSize: resultFontSize,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),
                              DataColumn(
                                label: Text(
                                  'Grade',
                                  style: TextStyle(
                                    fontSize: resultFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                            rows: subjects.map((subject) {
                              // Ensure that subjectResults is always initialized
                              var subjectResults = resultMap[subject] ?? {};
                              var subjectGradesCells = exams.map((exam) {
                                return DataCell(Text(
                                  subjectResults[exam] ?? '-',
                                  style: Font_Styles.dataTableRows(
                                      context, resultFontSize),
                                ));
                              }).toList();

                              // Calculate the grade for this subject
                              String grade = subjectGrades[subject] ?? '-';

                              // Add the grade cell to the end of the row
                              return DataRow(
                                color: MaterialStateProperty.all(
                                    AppColors.appOrange),
                                cells: [
                                  DataCell(Text(
                                    subject,
                                    style: Font_Styles.dataTableRows(
                                        context, resultFontSize),
                                  )),
                                  ...subjectGradesCells,
                                  DataCell(Text(
                                    grade,
                                    style: Font_Styles.dataTableRows(
                                        context, resultFontSize),
                                  )),
                                ],
                              );
                            }).toList(),
                            // DataCell(FutureBuilder<String>(
                            //   future:
                            //       controller.fetchTotalObtainedMarks(
                            //           controller
                            //               .student.value.studentID,
                            //           subject),
                            //   builder: (context, snapshot) {
                            //     if (snapshot.connectionState ==
                            //         ConnectionState.waiting) {
                            //       return Text(
                            //         '-',
                            //         style: TextStyle(
                            //           fontSize: resultFontSize,
                            //         ),
                            //       );
                            //     } else if (snapshot.hasError) {
                            //       return Text(
                            //         'Error',
                            //         style: TextStyle(
                            //           fontSize: resultFontSize,
                            //         ),
                            //       );
                            //     } else {
                            //       return Text(
                            //         snapshot.data ?? '0',
                            //         style: TextStyle(
                            //           fontSize: resultFontSize,
                            //         ),
                            //       );
                            //     }
                            //   },
                            // )),
                            // DataCell(FutureBuilder<String>(
                            //   future: controller
                            //       .fetchStudentTotalMarksSum(
                            //           controller
                            //               .student.value.studentID,
                            //           subject),
                            //   builder: (context, snapshot) {
                            //     if (snapshot.connectionState ==
                            //         ConnectionState.waiting) {
                            //       return Text(
                            //         '-',
                            //         style: TextStyle(
                            //           fontSize: resultFontSize,
                            //         ),
                            //       );
                            //     } else if (snapshot.hasError) {
                            //       return Text(
                            //         'Error',
                            //         style: TextStyle(
                            //           fontSize: resultFontSize,
                            //         ),
                            //       );
                            //     } else {
                            //       return Text(
                            //         snapshot.data ?? '0',
                            //         style: TextStyle(
                            //           fontSize: resultFontSize,
                            //         ),
                            //       );
                            //     }
                            //   },
                            // )),
                            // DataCell(Text(
                            //   calculateGrade(
                            //       resultMap[subject] ?? {}),
                            //   style: Font_Styles.dataTableRows(
                            //       context, resultFontSize),
                            // )),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }),
    );
  }

  // String calculateGrade(Map<String, String> subjectResults) {
  //   int totalMarks = 0;
  //   int obtainedMarks = 0;

  //   subjectResults.forEach((exam, marks) {
  //     if (marks.contains('/')) {
  //       var parts = marks.split('/');
  //       if (parts.length == 2) {
  //         obtainedMarks += int.tryParse(parts[0]) ?? 0;
  //         totalMarks += int.tryParse(parts[1]) ?? 0;
  //       }
  //     }
  //   });

  //   if (totalMarks == 0) {
  //     return '-';
  //   }

  //   double percentage = (obtainedMarks / totalMarks) * 100;
  //   if (percentage >= 90) {
  //     return 'A+';
  //   } else if (percentage >= 80) {
  //     return 'A';
  //   } else if (percentage >= 70) {
  //     return 'B';
  //   } else if (percentage >= 60) {
  //     return 'C';
  //   } else if (percentage >= 50) {
  //     return 'D';
  //   } else {
  //     return 'F';
  //   }
  // }
}
