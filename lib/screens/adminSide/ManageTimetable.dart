// ignore_for_file: invalid_use_of_protected_member

import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/screens/adminSide/AdminHome.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TimetableController extends GetxController {
  var classesList = <String>[].obs;
  var timetable = <String, dynamic>{}.obs; // Use .obs to make it reactive
  var selectedClass = ''.obs;
  var selectedDay = 'Monday'.obs;

  RxList<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday","Saturday"].obs;

  AdminHomeController school = Get.put(AdminHomeController());

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  void fetchClasses() async {
    try {
      classesList.assignAll(await Database_Service.fetchAllClassesbyTimetable(school.schoolId.value, true));

      if (classesList.isNotEmpty) {
        selectedClass.value = classesList.first;
        fetchTimetable();
      }
    } catch (e) {
      print("Error fetching classes: $e");
      Get.snackbar("Error", "Failed to fetch classes. Please try again later.");
    }
  }

  void fetchTimetable() async {
    try {
      Map<String, dynamic> fetchedTimetable =
          await Database_Service.fetchTimetable(school.schoolId.value, selectedClass.value, selectedDay.value);
      timetable.value = fetchedTimetable;
    } catch (e) {
      print("Error fetching timetable: $e");
      Get.snackbar("Error", "Failed to fetch timetable. Please try again later.");
    }
  }

  Future<void> refreshData() async {
    fetchClasses();
    fetchTimetable();
  }
}



class ManageTimetable extends StatelessWidget {
  final TimetableController controller = Get.put(TimetableController());

  @override
  Widget build(BuildContext context) {
    controller.refreshData();

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Manage Timetable", style: Font_Styles.labelHeadingLight(context)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          actions: [
            TextButton(
              onPressed: ()async {
                var result  =await Get.toNamed("/AddTimetable");
                print(result);
                if(result == 'updated'){
                  controller.refreshData();
                }
              },
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  'Add',
                  style: Font_Styles.labelHeadingLight(context,color: Colors.black),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            Get.toNamed("/DeleteTimetable");
          },
          child: Icon(Icons.delete_rounded, color: AppColors.appOrange),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 10, 5),
                  child: Text(
                    'Timetable',
                    style: Font_Styles.mediumHeadingBold(context),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 30, 5),
                child: Obx(() {
                  if (controller.classesList.isEmpty) {
                    return Center(
                      child: Text(
                        'No classes found',
                        style: Font_Styles.labelHeadingRegular(context),
                      ),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    value: controller.selectedClass.value,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.appOrange, width: 2.0),
                      ),
                    ),
                    items: controller.classesList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedClass.value = newValue;
                        // Fetch timetable for the newly selected class
                        controller.fetchTimetable();
                      }
                    },
                  );
                }),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
                child: Obx(() {
                  if (controller.days.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.appOrange,
                        ),
                      ),
                    );
                  }
                  return DropdownButtonFormField<String>(
                    value: controller.selectedDay.value,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.appOrange, width: 2.0),
                      ),
                    ),
                    items: controller.days.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedDay.value = newValue;
                        controller.fetchTimetable();
                      }
                    },
                  );
                }),
              ),
              Obx(() {
                if (controller.timetable.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Center(
                      child: Text(
                        'No timetable found for the selected class and day',
                        style: Font_Styles.labelHeadingRegular(context),
                      ),
                    ),
                  );
                }
      
                var timetableForClass = controller.timetable.value;
        
                var sortedEntries = timetableForClass.entries.toList()
                    ..sort((a, b) {
                      var startTimeA = _extractStartTime(a.value);
                      var startTimeB = _extractStartTime(b.value);
                      return startTimeA.compareTo(startTimeB);
                    });
      
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 80,
                    showCheckboxColumn: false,
                    showBottomBorder: true,
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Subject',
                          style: Font_Styles.labelHeadingRegular(context),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Start Time',
                          style: Font_Styles.labelHeadingRegular(context),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'End Time',
                          style: Font_Styles.labelHeadingRegular(context),
                        ),
                      ),
                    ],
                    rows: sortedEntries.map((entry) {
                      var subjectDetails = entry.value.split('-');
      
                      return DataRow(
                        color: MaterialStateColor.resolveWith((states) => AppColors.appOrange),
                        cells: [
                          DataCell(Text(entry.key)),
                          DataCell(Text(_formatTime(_extractStartTime(subjectDetails[0])))), // Display sorted start time
                          DataCell(Text(subjectDetails[1])),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _extractStartTime(String subjectDetail) {
    var startTime = subjectDetail.split(' - ')[0].trim(); 
    return _convertTimeToDateTime(startTime); 
  }

  String _formatTime(DateTime dateTime) {
    final format = DateFormat('h:mm a');
    return format.format(dateTime); 
  }

  DateTime _convertTimeToDateTime(String timeString) {
    final format = DateFormat('h:mm a'); 
    return format.parse(timeString); 
  }
}
