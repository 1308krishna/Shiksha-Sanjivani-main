// ignore_for_file: must_be_immutable

import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/screens/adminSide/AdminHome.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteTimeController extends GetxController {
  var classesList = <String>[].obs;
  var selectedClass = ''.obs;

  AdminHomeController school = Get.put(AdminHomeController());

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  void fetchClasses() async {
    try {
      classesList.assignAll(await Database_Service.fetchAllClassesbyTimetable(school.schoolId.value, true));

      if (classesList.isNotEmpty) {
        selectedClass.value = classesList.first;
      }
    } catch (e) {
      print("Error fetching classes: $e");
    }
  }

  void deleteTimetable(BuildContext context) async {
    try {
      Get.back(result: 'updated'); // Immediately pop the screen
      await Database_Service.deleteTimetableByClass(
        school.schoolId.value,
        selectedClass.value,
      );
      Get.snackbar("Deleted Successfully", "Class ${selectedClass.value} Timetable deleted");
    } catch (e) {
      if (context.mounted) {
        Get.snackbar("Error", "Failed to delete timetable");
      }
    }
  }
}

// ignore: use_key_in_widget_constructors
class DeleteTimetable extends StatelessWidget {
  DeleteTimeController controller = Get.put(DeleteTimeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delete Timetable"),
        actions: [
          Obx(() => controller.selectedClass.value.isNotEmpty
              ? TextButton(
                  onPressed: () => controller.deleteTimetable(context),
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : Text("Choose Class")),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(30, 20, 30, 5),
          child: Obx(() {
            if (controller.classesList.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.appOrange,
                  ),
                ),
              );
            }
            return DropdownButtonFormField<String>(
              hint: Text("Select Class"),
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
                }
              },
            );
          }),
        ),
      ),
    );
  }
}
