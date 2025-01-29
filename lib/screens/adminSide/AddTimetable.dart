import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/screens/adminSide/AdminHome.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddTimetableController extends GetxController {
  RxList<String> formats = ["Fixed Schedule", "Changed everyday"].obs;
  RxList<String> classes = <String>[].obs;
  RxList<String> subjects = <String>[].obs;
  RxString selectedFormat = "".obs;
  RxString selectedClass = "".obs;
  RxBool isSaturdayOn = false.obs;

  RxMap<String, RxMap<String, String>> startTimes = RxMap();
  RxMap<String, RxMap<String, String>> endTimes = RxMap();

  RxBool get isSaveEnabled => RxBool(
        startTimes.isNotEmpty &&
        endTimes.isNotEmpty &&
        startTimes.values.every((dayMap) => dayMap.isNotEmpty) &&
        endTimes.values.every((dayMap) => dayMap.isNotEmpty),
      );

  AdminHomeController school = Get.put(AdminHomeController());

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  void fetchClasses() async {
    classes.value = await Database_Service.fetchAllClassesbyTimetable(school.schoolId.value,false);
    update();
  }

  Future<void> fetchSubjects(String selectedClass) async {
    subjects.value = await Database_Service.fetchSubjects(school.schoolId.value, selectedClass);
    subjects.add("Break Time"); 
  }
}

class AddTimetable extends StatelessWidget {
  final AddTimetableController controller = Get.put(AddTimetableController());

  Future<void> saveTimetable() async {
    Map<String, Map<String, String>> timetableData = {};

    controller.subjects.forEach((subject) {
      controller.startTimes.forEach((dayLabel, startTimesMap) {
        if (dayLabel == "Monday - Thursday") {

          List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday"];

          for (String day in days) {
            String startTime = startTimesMap[subject] ?? '';
            String endTime = controller.endTimes[dayLabel]?[subject] ?? '';

            if (startTime.isNotEmpty && endTime.isNotEmpty) {
              if (!timetableData.containsKey(day)) {
                timetableData[day] = {};
              }
              timetableData[day]![subject] = '$startTime - $endTime';
            }
          }
        } else {
          String startTime = startTimesMap[subject] ?? '';
          String endTime = controller.endTimes[dayLabel]?[subject] ?? '';

          if (startTime.isNotEmpty && endTime.isNotEmpty) {
            if (!timetableData.containsKey(dayLabel)) {
              timetableData[dayLabel] = {};
            }
            timetableData[dayLabel]![subject] = '$startTime - $endTime';
          }
        }
      });
    });

    await Database_Service.addTimetablebyClass(
      controller.school.schoolId.value,
      controller.selectedClass.value,
      controller.selectedFormat.value,
      timetableData,
    );

    Get.back(result: 'updated');

    controller.startTimes.clear();
    controller.endTimes.clear();

  }

  Future<void> _selectTime(BuildContext context, RxMap<String, String> timeMap, String subject, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      String formattedTime = picked.format(context);
      if (isStartTime) {
        timeMap[subject] = formattedTime;
      } else {
        timeMap[subject] = formattedTime;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add timetable",
          style: Font_Styles.labelHeadingRegular(context),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isSaveEnabled.value
                  ? ()async {
                      await saveTimetable();
                      
                      
                    }
                  : null,
              child: Text(
                "Save",
                style: Font_Styles.labelHeadingRegular(context),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.1),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Container(
                      width: screenWidth * 0.7,
                      padding: EdgeInsets.only(right: screenWidth * 0.1),
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            hintText: "Select the class",
                            labelText: "Class",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: AppColors.appOrange,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                          ),
                          value: controller.selectedClass.value.isEmpty ? null : controller.selectedClass.value,
                          onChanged: (newValue) async {
                            controller.selectedClass.value = newValue!;
                            await controller.fetchSubjects(newValue); // Fetch subjects for selected class
                          },
                          items: controller.classes.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      width: screenWidth * 0.7,
                      child: Obx(
                        () => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            hintText: "Select the format",
                            labelText: "Format",
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: AppColors.appOrange,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                          ),
                          value: controller.selectedFormat.value.isEmpty ? null : controller.selectedFormat.value,
                          onChanged: (newValue) {
                            controller.selectedFormat.value = newValue!;
                          },
                          items: controller.formats.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Saturday On/Off"),
                    Obx(() => Switch.adaptive(
                      value: controller.isSaturdayOn.value,
                      onChanged: (value) {
                        controller.isSaturdayOn.value = value;
                      },
                    )),
                  ],
                ),

                if (controller.selectedFormat.value == "Fixed Schedule")
                  Obx(()=>
                     Column(
                      children: [
                        _buildDayTable("Monday - Thursday", context),
                        _buildDayTable("Friday", context),
                        controller.isSaturdayOn.value ? _buildDayTable("Saturday", context) : Container()
                      ],
                    ),
                  ),
                if (controller.selectedFormat.value == "Changed everyday")
                  Obx(()=>
                     Column(
                      children: [
                        _buildDayTable("Monday", context),
                        _buildDayTable("Tuesday", context),
                        _buildDayTable("Wednesday", context),
                        _buildDayTable("Thursday", context),
                        _buildDayTable("Friday", context),
                        controller.isSaturdayOn.value ? _buildDayTable("Saturday", context) : Container()
                    
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayTable(String dayLabel, BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dayLabel, style: Font_Styles.mediumHeadingBold(context)),
          DataTable(
            columns: [
              DataColumn(
                label: Text(
                  'Sr No.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Subject/Break Time',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Time',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            rows: List.generate(controller.subjects.length, (index) {
              String subject = controller.subjects[index];
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString(), style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03))),
                  DataCell(
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                        color: subject == "Break Time" ? AppColors.appOrange : Colors.black, // Special color for "Break Time"
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              await _selectTime(context, controller.startTimes.putIfAbsent(dayLabel, () => RxMap()), subject, true);
                            },
                            child: Obx(
                              () => Text(
                                controller.startTimes[dayLabel]?[subject] ?? 'Start Time',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              await _selectTime(context, controller.endTimes.putIfAbsent(dayLabel, () => RxMap()), subject, false);
                            },
                            child: Obx(
                              () => Text(
                                controller.endTimes[dayLabel]?[subject] ?? 'End Time',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
