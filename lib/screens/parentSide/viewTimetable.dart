// ignore_for_file: invalid_use_of_protected_member
import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/models/StudentModel.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ViewTimetableController extends GetxController {
  late Student student;
  var timetable = <String, dynamic>{}.obs;
  var selectedDay = 'Monday'.obs;
  var schoolId;
  RxList<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"].obs;


  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as List;
    schoolId = arguments[0] as String;
    student = arguments[1] as Student;
    refreshData();
  }


  void fetchTimetable() async {
    try {
        Map<String, dynamic> fetchedTimetable =
          await Database_Service.fetchTimetable(schoolId, student.classSection, selectedDay.value);
      timetable.value = fetchedTimetable;
    } catch (e) {
      print("Error fetching timetable: $e");
      Get.snackbar("Error", "Failed to fetch timetable. Please try again later.");
    }
  }

  Future<void> refreshData() async {
    fetchTimetable();
  }
}



class ViewTimetable extends StatelessWidget {
  final ViewTimetableController controller = Get.put(ViewTimetableController());

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
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () {
          //     Get.back();
          //   },
          // ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
