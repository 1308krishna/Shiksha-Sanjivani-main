import 'package:classinsight/models/StudentModel.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewAttendController extends GetxController {
  Rx<Student?> student = Rx<Student?>(null);
  RxString selectedMonth = ''.obs;
  RxString selectedSubject = ''.obs;
  RxDouble percentage = 10.0.obs;
  DateTime date = DateTime.now();
  RxMap<String, String> attendance = <String, String>{}.obs;
  RxList<String> subjectsList = <String>[].obs;
  RxList<String> monthsList = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'
  ].obs;

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = "${date.year}-${date.month.toString().padLeft(2, '0')}";
    fetchData();
  }

  Future<void> fetchData() async {
    student.value = Get.arguments as Student;
    if (student.value != null) {
      subjectsList.value = student.value?.attendance.keys.toList() ?? [];
      if (subjectsList.isNotEmpty) {
        selectedSubject.value = subjectsList.first;
      }
      filterAttendance();
      calculatePercentage();
    }
  }

  void filterAttendance() {
    final subjectAttendance = student.value?.attendance[selectedSubject.value];
    attendance.value = subjectAttendance?.entries
        .where((entry) => entry.key.startsWith(selectedMonth.value))
        .toMap((entry) => MapEntry(entry.key, entry.value)) ?? {};
  }

  void calculatePercentage() {
    int totalDays = attendance.length;
    int presentDays = attendance.values.where((status) => status == "Present").length;
    percentage.value = (totalDays > 0) ? (presentDays / totalDays) * 100 : 0.0;
  }

  Color getColorBasedOnPercentage(double percentage) {
    if (percentage < 50) {
      return Colors.red;
    } else if (percentage < 70 && percentage >= 50) {
      return AppColors.appOrange;
    } else {
      return AppColors.appDarkBlue;
    }
  }

  void updateSelectedMonth(String month) {
    int monthIndex = monthsList.indexOf(month) + 1;
    selectedMonth.value = "${date.year}-${monthIndex.toString().padLeft(2, '0')}";
    filterAttendance();
    calculatePercentage();
  }

  void updateSelectedSubject(String subject) {
    selectedSubject.value = subject;
    filterAttendance();
    calculatePercentage();
  }
}

extension IterableToMap<K, V> on Iterable<MapEntry<K, V>> {
  Map<K, V> toMap(MapEntry<K, V> Function(MapEntry<K, V>) map) {
    return {for (var entry in this) map(entry).key: map(entry).value};
  }
}




class ViewAttendance extends StatelessWidget {
  ViewAttendance({super.key});

  final ViewAttendController controller = Get.put(ViewAttendController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance", style: Font_Styles.labelHeadingRegular(context)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.student.value == null) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Text(controller.student.value!.name, style: Font_Styles.cardLabel(context)),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: DropdownButtonFormField<String>(
                value: controller.monthsList[controller.date.month - 1],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.appLightBlue, width: 2.0),
                  ),
                ),
                items: controller.monthsList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.updateSelectedMonth(newValue);
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: DropdownButtonFormField<String>(
                value: controller.selectedSubject.value,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.appLightBlue, width: 2.0),
                  ),
                ),
                items: controller.subjectsList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.updateSelectedSubject(newValue);
                  }
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 290,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.getColorBasedOnPercentage(controller.percentage.value),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Obx(() {
                      return CircularProgressIndicator(
                        value: controller.percentage.value / 100,
                        strokeWidth: 5,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeCap: StrokeCap.round,
                      );
                    }),
                  ),
                  Obx(() {
                    return Text(
                      "${controller.percentage.value.toStringAsFixed(1)}%",
                      style: Font_Styles.labelHeadingRegular(context, color: Colors.black),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(() {
                        return ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: 
                          controller.attendance.entries.isNotEmpty ?
                          DataTable(
                            columnSpacing: screenWidth * 0.1,
                            sortAscending: false,
                            sortColumnIndex: 1,
                            dataRowColor: MaterialStateColor.resolveWith(
                                (states) => AppColors.appDarkBlue),
                            columns: [
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Attendance')),
                            ],
                            rows: controller.attendance.entries.map((entry) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(entry.key)),
                                  DataCell(Text(entry.value)),
                                ],
                              );
                            }).toList(),
                          ): Center(child: Text('No attendance for ${controller.selectedMonth.value} and ${controller.selectedSubject.value}')),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

