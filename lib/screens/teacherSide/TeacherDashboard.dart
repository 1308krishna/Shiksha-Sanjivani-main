import 'package:classinsight/Services/Auth_Service.dart';
import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/models/TeacherModel.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class TeacherDashboardController extends GetxController {
  RxInt height = 120.obs;
  Rx<Teacher?> teacher = Rx<Teacher?>(null);
  Rx<School?> school = Rx<School?>(null);
  final GetStorage _storage = GetStorage();
  var subjectsList = <String>[].obs;
  var classesList = <String>[].obs;
  var selectedClass = ''.obs;
  var arguments;

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
      teacher.value = arguments[0] as Teacher?;
      school.value = arguments[1] as School?;

      if (teacher.value != null && school.value != null) {
        cacheData(school.value!, teacher.value!);
      }
    } else {
      loadCachedData();
    }

    fetchClasses();

    if (classesList.isNotEmpty) {
      selectedClass.value = classesList.first;
      updateSubjects(selectedClass.value);
    }

    setupRealTimeListeners();
  }

  void fetchClasses() {
    if (teacher.value != null) {
      classesList.value = teacher.value!.classes;
    }
  }

  void loadCachedData() {
    var cachedSchool = _storage.read('cachedSchool');
    if (cachedSchool != null) {
      school.value = School.fromJson(cachedSchool);
    }
    var cachedTeacher = _storage.read('cachedTeacher');
    if (cachedTeacher != null) {
      teacher.value = Teacher.fromJson(cachedTeacher);
    }
  }

  void cacheData(School school, Teacher teacher) {
    print('Caching data');
    _storage.write('cachedSchool', school.toJson());
    _storage.write('cachedTeacher', teacher.toJson());
    _storage.write('isTeacherLogged', true);
    print('Data cached');
  }

  void clearCachedData() {
    _storage.remove('cachedSchool');
    _storage.remove('cachedTeacher');
    _storage.remove('isTeacherLogged');
  }

  void updateData(School school, Teacher teacher) {
    this.school.value = school;
    this.teacher.value = teacher;
    cacheData(school, teacher);
    fetchClasses();
  }

  void updateSubjects(String selectedClass) {
    subjectsList.value = teacher.value!.subjects[selectedClass] ?? [];
  }

  void setupRealTimeListeners() {
    if (teacher.value != null && school.value != null) {
      FirebaseFirestore.instance
          .collection('Teachers')
          .doc()
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          Teacher updatedTeacher = Teacher.fromJson(snapshot.data()!);
          teacher.value = updatedTeacher;
          cacheData(school.value!, updatedTeacher);
          fetchClasses();
        }
      });

      FirebaseFirestore.instance
          .collection('Schools')
          .doc(school.value!.schoolId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          School updatedSchool = School.fromJson(snapshot.data()!);
          school.value = updatedSchool;
          cacheData(updatedSchool, teacher.value!);
        }
      });
    }
  }
}

class TeacherDashboard extends StatelessWidget {
  TeacherDashboard({super.key});

  final TeacherDashboardController _controller =
      Get.put(TeacherDashboardController());

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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Hi, ${_controller.teacher.value!.name}",
                  style: Font_Styles.mediumHeadingBold(context),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  _controller.teacher.value!.email,
                  style: Font_Styles.labelHeadingRegular(context),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Class Teacher: ${_controller.teacher.value!.classTeacher}',
                  style: Font_Styles.labelHeadingLight(context),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  _controller.teacher.value!.subjects.toString(),
                  style: Font_Styles.labelHeadingLight(context),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(30, 0, 10, 5),
                            child: Text(
                              'Class',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Obx(
                            () => Padding(
                              padding: EdgeInsets.fromLTRB(30, 0, 30, 15),
                              child: DropdownButtonFormField<String>(
                                value: _controller.classesList.contains(
                                        _controller.selectedClass.value)
                                    ? _controller.selectedClass.value
                                    : null,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: AppColors.appLightBlue,
                                        width: 2.0),
                                  ),
                                ),
                                items:
                                    _controller.classesList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  _controller.selectedClass.value =
                                      newValue ?? '';
                                  _controller.updateSubjects(newValue ?? '');
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed("/MarkAttendance", arguments: [
                                  _controller.school.value!.schoolId,
                                  _controller.selectedClass.value,
                                  _controller.teacher.value!.name,
                                  _controller.subjectsList
                                ]);
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
                                        child: Text('Attendance',
                                            style: Font_Styles.cardLabel(
                                                context,
                                                color: AppColors.appLightBlue)),
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
                                Get.toNamed('/DisplayMarks', arguments: [
                                  _controller.school.value!.schoolId,
                                  _controller.selectedClass.value,
                                  _controller.teacher.value
                                ]);
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
                                          'Marks',
                                          style: TextStyle(
                                            color: AppColors.appOrange,
                                            fontSize: 20,
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
