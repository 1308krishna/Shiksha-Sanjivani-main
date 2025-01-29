import 'dart:async';

import 'package:classinsight/Services/Database_Service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/Services/Auth_Service.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:classinsight/Widgets/shadowButton.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminHomeController extends GetxController {
  var email = 'test@gmail.com'.obs;
  var schoolName = 'School1'.obs;
  var schoolId = "j".obs;
  RxString totalStudents = '0'.obs;
  RxString totalTeachers = '0'.obs;
  RxInt height = 120.obs;
  Rx<School?> school = Rx<School?>(null);
  final GetStorage _storage = GetStorage();
  StreamSubscription? studentsSubscription;
  StreamSubscription? teachersSubscription;

  @override
  void onInit() {
    super.onInit();
    loadCachedSchoolData();
    var schoolFromArguments = Get.arguments;
    if (schoolFromArguments != null) {
      cacheSchoolData(schoolFromArguments);
      updateSchoolData(schoolFromArguments);
    }
    totalInformation();
    startListeners();
  }

  @override
  void onClose() {
    studentsSubscription?.cancel();
    teachersSubscription?.cancel();
    super.onClose();
  }

  void totalInformation() async {
    print(schoolName.value);
    print(schoolId.value);
    totalTeachers.value = await Database_Service.fetchCounts(schoolName.value, "Teachers");
    totalStudents.value = await Database_Service.fetchCounts(schoolName.value, "Students");
    cacheTotalCounts();
    update();
  }

  void startListeners() async {
  try {
    // Ensure schoolId is not empty
    if (schoolId.value.isEmpty) {
      print('Error: schoolId is empty');
      totalStudents.value = '0';
      totalTeachers.value = '0';
      return;
    }

    final schoolRef = FirebaseFirestore.instance.collection('Schools').doc(schoolId.value);

    // Check if the document exists
    final schoolDocSnapshot = await schoolRef.get();
    if (!schoolDocSnapshot.exists) {
      print('Error: School document does not exist');
      totalStudents.value = '0';
      totalTeachers.value = '0';
      return;
    }

    // Check if the Students collection exists
    final studentsCollectionRef = schoolRef.collection('Students');
    final studentsSnapshot = await studentsCollectionRef.limit(1).get();
    if (studentsSnapshot.docs.isEmpty) {
      totalStudents.value = '0';
    } else {
      // Start listening if the collection exists
      studentsSubscription = studentsCollectionRef.snapshots().listen((snapshot) {
        totalStudents.value = snapshot.size.toString();
        cacheTotalCounts();
      });
    }

    // Check if the Teachers collection exists
    final teachersCollectionRef = schoolRef.collection('Teachers');
    final teachersSnapshot = await teachersCollectionRef.limit(1).get();
    if (teachersSnapshot.docs.isEmpty) {
      totalTeachers.value = '0';
    } else {
      // Start listening if the collection exists
      teachersSubscription = teachersCollectionRef.snapshots().listen((snapshot) {
        totalTeachers.value = snapshot.size.toString();
        cacheTotalCounts();
      });
    }
  } catch (e) {
    print('Error starting listeners: $e');
    totalStudents.value = '0';
    totalTeachers.value = '0';
  }
}


  void clearCachedSchoolData() {
    _storage.remove('cachedSchool');
    _storage.remove('totalTeachers');
    _storage.remove('totalStudents');
  }

  void loadCachedSchoolData() {
    var cachedSchool = _storage.read('cachedSchool');
    if (cachedSchool != null) {
      school.value = School.fromJson(cachedSchool);
      updateSchoolData(school.value!);
    }
    var cachedTotalTeachers = _storage.read('totalTeachers');
    if (cachedTotalTeachers != null) {
      totalTeachers.value = cachedTotalTeachers;
    }
    var cachedTotalStudents = _storage.read('totalStudents');
    if (cachedTotalStudents != null) {
      totalStudents.value = cachedTotalStudents;
    }
  }

  void cacheSchoolData(School school) {
    _storage.write('cachedSchool', school.toJson());
  }

  void cacheTotalCounts() {
    _storage.write('totalTeachers', totalTeachers.value);
    _storage.write('totalStudents', totalStudents.value);
  }

  void updateSchoolData(School school) {
    totalStudents.value = '-';
    totalTeachers.value = '-';
    this.school.value = school;
    schoolId.value = school.schoolId;
    email.value = school.adminEmail;
    schoolName.value = school.name;

     print("Updated schoolId: ${this.schoolId.value}");
  print("Updated schoolName: ${schoolName.value}");
  print("Updated email: ${email.value}");

    if (totalTeachers.value == '-' || totalStudents.value == '-') {
      totalInformation();
    }
    startListeners();
  }
}



class AdminHome extends StatelessWidget {
  AdminHome({Key? key}) : super(key: key);

  final AdminHomeController _controller = Get.put(AdminHomeController());

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
        title: Text(
          "Dashboard",
          style: Font_Styles.labelHeadingLight(context),
        ),
        backgroundColor: AppColors.appLightBlue,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Auth_Service.logout(context);
              _controller.clearCachedSchoolData();
            },
            icon: Icon(Icons.logout_rounded, color: Colors.black),
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical:8
                ),
                child: Text(
                  "Hi, Admin",
                  style: Font_Styles.largeHeadingBold(context),
                ),
              ),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical:8
                ),
                  child: Text(
                    _controller.email.value,
                    style: Font_Styles.labelHeadingRegular(context),
                  ),
                ),
              ),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical:10
                ),
                  child: Text(
                    _controller.schoolName.value,
                    style: Font_Styles.labelHeadingLight(context),
                  ),
                ),
              ),
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
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: screenWidth * 0.4,
                                  height: _controller.height.value.toDouble(),
                                  // decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(15),
                                  //     color: AppColors.appLightBlue,
                                  //     border: Border.all(color: Colors.black)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.01,
                                        vertical: screenHeight * 0.01),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesomeIcons.userGraduate),
                                        Obx(() {
                                          return Text(
                                            _controller.totalStudents.value,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            style: Font_Styles
                                                .mediumHeadingBold(context),
                                          );
                                        }),
                                        Text(
                                          "Total Students Registered",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: Font_Styles
                                              .labelHeadingRegular(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: screenWidth * 0.4,
                                  height: _controller.height.value.toDouble(),
                                  // decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(15),
                                  //     color: AppColors.appLightBlue,
                                  //     border: Border.all(color: Colors.black)),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.01,
                                        vertical: screenHeight * 0.01),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(FontAwesomeIcons.graduationCap),
                                        Obx(() {
                                          return Text(
                                            _controller.totalTeachers.value,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            style: Font_Styles
                                                .mediumHeadingBold(context),
                                          );
                                        }),
                                        Text(
                                          "Total Teachers Registered",
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                          style: Font_Styles
                                              .labelHeadingRegular(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              ShadowButton(
                                text: "Manage Students",
                                onTap: () {
                                  Get.toNamed("/ManageStudents");
                                },
                              ),
                              Spacer(),
                              ShadowButton(
                                text: "Manage Teachers",
                                onTap: () {
                                  Get.toNamed("/ManageTeachers", arguments: _controller.school.value);
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              ShadowButton(
                                text: "Manage Timetable",
                                onTap: () {
                                  Get.toNamed("/ManageTimetable");
                                },
                              ),
                              Spacer(),
                              ShadowButton(
                                text: "Make Announcements",
                                onTap: () {
                                  Get.toNamed("/MakeAnnouncements");
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              ShadowButton(
                                text: "Classes, Sections and Subjects",
                                onTap: () {
                                  Get.toNamed("/AddClassSections");
                                },
                              ),
                              Spacer(),
                              ShadowButton(
                                text: "Results",
                                onTap: () {
                                  Get.toNamed("/SubjectResult");
                                },
                              ),
                            ],
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