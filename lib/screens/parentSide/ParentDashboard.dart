import 'dart:async';

import 'package:classinsight/Services/Auth_Service.dart';
import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/models/AnnouncementsModel.dart';
import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/models/StudentModel.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class ParentDashboardController extends GetxController {
  RxInt height = 120.obs;
  Rx<Student?> student = Rx<Student?>(null);
  Rx<School?> school = Rx<School?>(null);
  RxList<Announcement> mainAnnouncements = <Announcement>[].obs;
  RxList<Announcement> teacherComments = <Announcement>[].obs;
  var selectedClass = ''.obs;
  var feedetails = ''.obs;
  RxBool isLoading = true.obs;
  Color feeColor = Colors.red;
  final GetStorage _storage = GetStorage();
  var arguments;
  StreamSubscription<DocumentSnapshot>? studentSubscription;
  StreamSubscription<DocumentSnapshot>? schoolSubscription;

  @override
  void onInit() {
    super.onInit();
    try {
      arguments = Get.arguments as List?;
    } catch (e) {
      print(e);
      loadCachedData();
    }
    if (arguments != null && arguments.length >= 2) {
      print('I am in if');
      student.value = arguments[0] as Student?;
      school.value = arguments[1] as School?;

      if (student.value != null && school.value != null) {
        cacheData(school.value!, student.value!);
        addListeners();
      }
    } else {
      loadCachedData();
    }
    feeStatus();
    fetchAnnouncements();
  }

  @override
  void onClose() {
    super.onClose();
    studentSubscription?.cancel();
    schoolSubscription?.cancel();
  }

  void loadCachedData() {
    var cachedSchool = _storage.read('cachedSchool');
    if (cachedSchool != null) {
      school.value = School.fromJson(cachedSchool);
      if (school.value != null) {
        addListeners();
      }
    }
    var cachedStudent = _storage.read('cachedStudent');
    if (cachedStudent != null) {
      student.value = Student.fromJson(cachedStudent);
    }
  }

  void cacheData(School school, Student student) {
    print('Caching data');
    _storage.write('cachedSchool', school.toJson());
    _storage.write('cachedStudent', student.toJson());
    _storage.write('isParentLogged', true);
    print('Data cached');
  }

  void clearCachedData() {
    _storage.remove('cachedSchool');
    _storage.remove('cachedStudent');
    _storage.remove('isParentLogged');
  }

  void updateData(School school, Student student) {
    this.school.value = school;
    this.student.value = student;
    cacheData(school, student);
  }

  void feeStatus() {
    if (student.value != null && student.value!.feeStatus == 'paid') {
      feedetails.value = '${student.value!.feeStatus} (${student.value!.feeStartDate} ${student.value!.feeEndDate})';
      feeColor = Colors.green;
    } else {
      feeColor = Colors.red;
    }
  }

  void fetchAnnouncements() async {
    if (school.value != null && student.value != null) {
      isLoading.value = true;

      final adminAnnouncements = await Database_Service.fetchAdminAnnouncements(
          school.value!.schoolId);
      if (adminAnnouncements != null) {
        mainAnnouncements.assignAll(adminAnnouncements);
      }

      final studentAnnouncements = await Database_Service.fetchStudentAnnouncements(
          school.value!.schoolId, student.value!.studentID);
      if (studentAnnouncements != null) {
        teacherComments.assignAll(studentAnnouncements);
      }

      isLoading.value = false;
    }
  }

  void addListeners() {
    if (school.value != null && student.value != null) {
      studentSubscription = FirebaseFirestore.instance
          .collection('Schools')
          .doc(school.value!.schoolId)
          .collection('Students')
          .doc(student.value!.studentID)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          student.value = Student.fromJson(snapshot.data()!);
          feeStatus();
        }
      });

      schoolSubscription = FirebaseFirestore.instance
          .collection('Schools')
          .doc(school.value!.schoolId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          school.value = School.fromJson(snapshot.data()!);
        }
      });
    }
  }
}



class ParentDashboard extends StatelessWidget {
  ParentDashboard({super.key});

  final ParentDashboardController _controller =
      Get.put(ParentDashboardController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 350 && screenWidth <= 400) {
      _controller.height.value = 135;
    } else if (screenWidth > 400 && screenWidth <= 500) {
      _controller.height.value = 160;
    } else if (screenWidth > 500 && screenWidth <= 768) {
      _controller.height.value = 220;
    } else if (screenWidth > 768) {
      _controller.height.value = 270;
    }

    return Scaffold(
      backgroundColor: AppColors.appLightBlue,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          "Dashboard",
          style: Font_Styles.labelHeadingLight(context),
        ),
        backgroundColor: AppColors.appLightBlue,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _controller.clearCachedData();
              Auth_Service.logout(context);
            },
            icon: Icon(Icons.logout_rounded, color: Colors.black),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  "Hi, ${_controller.student.value!.name}",
                  style: Font_Styles.mediumHeadingBold(context),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Text(
                  'Father Name: ' + _controller.student.value!.fatherName,
                  style: Font_Styles.labelHeadingRegular(context),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Text(
                  'Roll No: ${_controller.student.value!.studentRollNo}',
                  style: Font_Styles.labelHeadingLight(context),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Text(
                  'Class: ${_controller.student.value!.classSection}',
                  style: Font_Styles.labelHeadingLight(context),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Text(
                  'Fee Status: ${_controller.feedetails}',
                  style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      color: _controller.feeColor,
                    ),
                ),
              ),
              SizedBox(height: screenHeight*0.02,),
              Expanded(
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.82,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Obx(() {
                              if (_controller.isLoading.value) {
                                return Center(
                                    child:
                                        CircularProgressIndicator(backgroundColor: AppColors.appLightBlue));
                              } else {
                                return Container(
                                  height: screenHeight * 0.16,
                                  width: screenWidth - 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 2,
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                15, 10, 0, 0),
                                            child: Text('Last 7 days'),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                15, 0, 0, 0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Announcements:',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.02),
                                                Icon(Icons.announcement,
                                                    size: screenWidth * 0.05,
                                                    color: AppColors.appPink),
                                              ],
                                            ),
                                          ),
                                          Obx(() {
                                            return ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: _controller
                                                  .mainAnnouncements.length,
                                              itemBuilder: (context, index) {
                                                final announcement = _controller
                                                    .mainAnnouncements[index];
                                                return ListTile(
                                                  title: Text(announcement
                                                          .announcementDescription ??
                                                      ''),
                                                  subtitle: Text('-' + announcement
                                                          .announcementBy!
                                                  ),
                                                );
                                              },
                                            );
                                          }),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                15, 0, 0, 0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Teacher Weekly Comments:',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        screenWidth * 0.04,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: screenWidth * 0.02),
                                                Icon(Icons.comment,
                                                    size: screenWidth * 0.05,
                                                    color: AppColors.appPink),
                                              ],
                                            ),
                                          ),
                                          Obx(() {
                                            return ListView.builder(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemCount: _controller
                                                  .teacherComments.length,
                                              itemBuilder: (context, index) {
                                                final comment = _controller
                                                    .teacherComments[index];
                                                    debugPrint(comment.announcementDescription);
                                                return ListTile(
                                                  title: Text(comment
                                                          .announcementDescription ??
                                                      ''),
                                                  subtitle: Text('-' + 
                                                      comment.announcementBy!),
                                                );
                                              },
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed("/ViewTimetable", arguments: [
                                  _controller.school.value!.schoolId,
                                  _controller.student.value
                                ]);
                              },
                              child: Container(
                                height: screenHeight * 0.16,
                                width: screenWidth - 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.appPink,
                                    width: 1,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Icon(Icons.schedule,
                                            size: 50, color: AppColors.appPink),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          'Timetable',
                                          style: TextStyle(
                                            color: AppColors.appPink,
                                            fontSize: 20, // Adjust as needed
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                print(_controller.student);
                                Get.toNamed("/ViewAttendance",
                                    arguments: _controller.student.value);
                              },
                              child: Container(
                                height: screenHeight * 0.16,
                                width: screenWidth - 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.appDarkBlue,
                                    width: 1,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Icon(Icons.people,
                                            size: 50,
                                            color: AppColors.appDarkBlue),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          'Attendance Status',
                                          style: TextStyle(
                                            color: AppColors.appDarkBlue,
                                            fontSize: 20, // Adjust as needed
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                print(_controller.student.value!.studentID);
                                print(_controller.school.value!.schoolId);
                                Get.toNamed(
                                  '/Result',
                                  arguments: {
                                    'student': _controller.student.value,
                                    'schoolId': _controller.school.value!
                                        .schoolId, // Make sure `schoolId` is accessible here
                                  },
                                );
                              },
                              child: Container(
                                height: screenHeight * 0.16,
                                width: screenWidth - 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.appOrange,
                                    width: 1,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Icon(Icons.book,
                                            size: 50,
                                            color: AppColors.appOrange),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        child: Text(
                                          'Result',
                                          style: TextStyle(
                                            color: AppColors.appOrange,
                                            fontSize: 20, // Adjust as needed
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
            ],
          ),
        ],
      ),
    );
  }
}
