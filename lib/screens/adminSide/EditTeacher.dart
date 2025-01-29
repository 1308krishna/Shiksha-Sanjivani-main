import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/Widgets/CustomTextField.dart';
import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/models/TeacherModel.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class ClassSubject {
  String className;
  List<String> subjects;

  ClassSubject({required this.className, required this.subjects});
}

class EditTeacherController extends GetxController {
  String changedGender = '';
  String changedClassTeacher = '';
  Map<String, List<String>> subjects = {};
  List<String> existingClasses = [];
  Map<String, List<String>> existingSubjects = {};
  RxList<ClassSubject> classesSubjects = <ClassSubject>[].obs;
  RxList<String> selectedClasses = <String>[].obs;
  RxMap<String, List<String>> selectedSubjects = <String, List<String>>{}.obs;
  RxString name = 'Initial Name'.obs;

  TextEditingController nameController = TextEditingController();
  TextEditingController updatedController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cnicController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();

  var genderValid = true.obs;
  var emailValid = true.obs;
  var cnicValid = true.obs;
  var nameValid = true.obs;
  var fatherNameValid = true.obs;
  var phoneNoValid = true.obs;
  RxString schoolId = ''.obs;
  var selectedGender = ''.obs;
  var selectedClassTeacher = ''.obs;
  var existingClassTeacher = ''.obs;
  late School school;
  late Teacher teacher;
  var addStdFontSize = 16.0;
  var headingFontSize = 33.0;
  var isLoading = true.obs;
  List arguments = Get.arguments;

  @override
  void onInit() {
    super.onInit();
    teacher = arguments[0] as Teacher;
    school = arguments[1] as School;
    schoolId.value = school.schoolId;
    initializeData(teacher);
    fetchClassesAndSubjects();
  }

  void fetchClassesAndSubjects() async {
    isLoading.value = true;

    Map<String, List<String>> classesAndSubjectsMap =
        await Database_Service.fetchClassesAndSubjects(schoolId.value);
    List<ClassSubject> fetchedClassesSubjects = [];

    classesAndSubjectsMap.forEach((className, subjects) {
      fetchedClassesSubjects
          .add(ClassSubject(className: className, subjects: subjects));
    });

    classesSubjects.assignAll(fetchedClassesSubjects);
    isLoading.value = false;
  }

  void initializeData(Teacher teacher) {
    name.value = teacher.name;
    updatedController.text = teacher.name;
    cnicController.text = teacher.cnic;
    phoneNoController.text = teacher.phoneNo;
    fatherNameController.text = teacher.fatherName;
    selectedGender.value = teacher.gender;
    emailController.text = teacher.email;
    existingClassTeacher.value = teacher.classTeacher;
    selectedClassTeacher.value = teacher.classTeacher;
    existingClasses = teacher.classes;
    existingSubjects = teacher.subjects;
    selectedClasses.assignAll(teacher.classes);
    selectedSubjects.assignAll(teacher.subjects);
  }

  String capitalizeName(String name) {
    List<String> parts = name.split(' ');
    return parts.map((part) => _capitalize(part)).join(' ');
  }

  String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  void showEditNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          backgroundColor: AppColors.appLightBlue,
          content: TextField(
            controller: updatedController,
            decoration: const InputDecoration(
              hintText: 'Enter new name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                print(updatedController.text);
                name.value = updatedController.text;
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}

class EditTeacher extends StatelessWidget {
  EditTeacher({Key? key}) : super(key: key);

  final EditTeacherController controller = Get.put(EditTeacherController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 350) {
      controller.addStdFontSize = 14.0;
      controller.headingFontSize = 27.0;
    }
    if (screenWidth < 300) {
      controller.addStdFontSize = 14.0;
      controller.headingFontSize = 24.0;
    }
    if (screenWidth < 250) {
      controller.addStdFontSize = 11.0;
      controller.headingFontSize = 20.0;
    }
    if (screenWidth < 230) {
      controller.addStdFontSize = 8.0;
      controller.headingFontSize = 15.0;
    }

    return Scaffold(
      backgroundColor: AppColors.appLightBlue,
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
                    backgroundColor: AppColors.appLightBlue,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    title: Text(
                      'Teachers',
                      style: Font_Styles.labelHeadingLight(context),
                    ),
                    centerTitle: true,
                    actions: <Widget>[
                      Container(
                        width: 48.0,
                      ),
                      TextButton(
                        onPressed: () {
                          if (controller.selectedGender.value.isEmpty ||
                              controller.phoneNoController.text.isEmpty ||
                              controller.emailController.text.isEmpty ||
                              controller.cnicController.text.isEmpty ||
                              controller.fatherNameController.text.isEmpty ||
                              controller.selectedClasses.isEmpty ||
                              controller.selectedSubjects.isEmpty) {
                            Get.snackbar('No Changes Made',
                                'Please make some changes to update the teacher');
                          } else if (controller.selectedSubjects.values
                              .every((subjects) => subjects.isNotEmpty)) {
                            print(controller.selectedClassTeacher.value);

                            String capitalizedName = controller
                                .capitalizeName(controller.name.value);
                            String capitalizedFatherName =
                                controller.capitalizeName(
                                    controller.fatherNameController.text);

                            Database_Service.updateTeacher(
                                controller.schoolId.value,
                                controller.teacher.empID,
                                capitalizedName,
                                controller.selectedGender.value,
                                controller.emailController.text,
                                controller.phoneNoController.text,
                                controller.cnicController.text,
                                capitalizedFatherName,
                                controller.selectedClasses,
                                controller.selectedSubjects,
                                controller.selectedClassTeacher.value);

                            Get.snackbar('Teacher Updated',
                                'The teacher has been updated successfully');
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            
                          } else {
                            Get.snackbar('No Subjects Selected',
                                'Please select subjects for all the classes');
                          }
                        },
                        child: Text(
                          "Update",
                          style: Font_Styles.labelHeadingLight(context,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, screenHeight * 0.03),
                  child: Container(
                    height: 0.05 * screenHeight,
                    width: screenWidth,
                    margin: const EdgeInsets.only(bottom: 10.0),
                    child: Text('Edit Teacher',
                        textAlign: TextAlign.center,
                        style: Font_Styles.dataTableTitle(
                            context, controller.headingFontSize)),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 4,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                0, screenHeight * 0.03, 0, screenHeight * 0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 0, 20, 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Obx(() => Text(
                                              controller.name.value,
                                              style: Font_Styles.dataTableTitle(
                                                  context,
                                                  controller.headingFontSize -
                                                      10),
                                              softWrap: true,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          controller
                                              .showEditNameDialog(context);
                                        },
                                      ),
                                    ],
                                  ),
                                )),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 30, 0),
                                  child: Text(
                                    controller.teacher.empID,
                                    style: Font_Styles.dataTableTitle(
                                        context, controller.addStdFontSize),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                30, 0, 60, screenHeight * 0.01),
                            child: Obx(
                              () =>  Text(
                              'Classes Teacher: ${controller.selectedClassTeacher.value}',
                              style: Font_Styles.dataTableTitle(
                                  context, controller.addStdFontSize),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                30, 0, 60, screenHeight * 0.04),
                            child: Obx(
                              () => Text(
                                'Classes & Subjects: ${controller.selectedSubjects}',
                                style: Font_Styles.dataTableTitle(
                                    context, controller.addStdFontSize),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.white,
                              ),
                              child: Obx(
                                () => DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    hintText: "Select your gender",
                                    labelText: "Gender",
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(
                                          color: AppColors.appLightBlue,
                                          width: 2.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1.0),
                                    ),
                                  ),
                                  value: controller.selectedGender.value.isEmpty
                                      ? null
                                      : controller.selectedGender.value,
                                  onChanged: (newValue) {
                                    controller.selectedGender.value = newValue!;
                                  },
                                  items: <String>['Male', 'Female', 'Other']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: CustomTextField(
                              controller: controller.emailController,
                              hintText: 'jhondoe@....com',
                              labelText: 'Email',
                              isValid: controller.emailValid.value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: CustomTextField(
                              controller: controller.cnicController,
                              hintText: '352020xxxxxxxx91',
                              labelText: 'CNIC No',
                              isValid: controller.cnicValid.value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: CustomTextField(
                              controller: controller.phoneNoController,
                              hintText: '0321xxxxxx12',
                              labelText: 'Phone Number',
                              isValid: controller.phoneNoValid.value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: CustomTextField(
                              controller: controller.fatherNameController,
                              hintText: "Father's name",
                              labelText: "Father's name",
                              isValid: controller.fatherNameValid.value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: Obx(() {
                              if (controller.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.appDarkBlue),
                                );
                              } else {
                                return Column(
                                  children: [
                                    MultiSelectDialogField(
                                        backgroundColor: AppColors.appLightBlue,
                                        items: controller.classesSubjects
                                            .map((classSubject) =>
                                                MultiSelectItem(
                                                    classSubject.className,
                                                    classSubject.className))
                                            .toList(),
                                        title: const Text("Available Classes"),
                                        selectedColor: Colors.black,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                        ),
                                        buttonIcon: const Icon(
                                          Icons.class_,
                                          color: Colors.black,
                                        ),
                                        buttonText: Text(
                                          "Class to Assign",
                                          style:
                                              Font_Styles.labelHeadingRegular(
                                                  context),
                                        ),
                                        checkColor: Colors.white,
                                        cancelText: Text(
                                          "Cancel",
                                          style:
                                              Font_Styles.labelHeadingRegular(
                                                  context),
                                        ),
                                        confirmText: Text(
                                          "Ok",
                                          style:
                                              Font_Styles.labelHeadingRegular(
                                                  context),
                                        ),
                                        initialValue:
                                            controller.selectedClasses,
                                        onConfirm: (results) {
                                          controller.selectedClasses.clear();
                                          controller.selectedClasses
                                              .assignAll(results);

                                          RxMap<String, List<String>>
                                              updatedSubjects =
                                              <String, List<String>>{}.obs;

                                          for (var selectedClass in results) {
                                            if (controller.selectedSubjects
                                                .containsKey(selectedClass)) {
                                              updatedSubjects[selectedClass] =
                                                  controller.selectedSubjects[
                                                      selectedClass]!;
                                            }
                                          }

                                          controller.selectedSubjects.value =
                                              updatedSubjects;
                                        }),
                                    Obx(() => Column(
                                          children: [
                                            for (var className
                                                in controller.selectedClasses)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 20, 0, 20),
                                                child: MultiSelectDialogField(
                                                  backgroundColor:
                                                      AppColors.appLightBlue,
                                                  items: controller
                                                      .classesSubjects
                                                      .firstWhere(
                                                          (classSubject) =>
                                                              classSubject
                                                                  .className ==
                                                              className)
                                                      .subjects
                                                      .map((subject) =>
                                                          MultiSelectItem(
                                                              subject, subject))
                                                      .toList(),
                                                  title: Text(
                                                      "Subjects for $className"),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      Radius.circular(10),
                                                    ),
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  buttonIcon: const Icon(
                                                    Icons.subject,
                                                    color: Colors.black,
                                                  ),
                                                  buttonText: Text(
                                                    "Select Subjects for $className",
                                                    style: Font_Styles
                                                        .labelHeadingRegular(
                                                            context),
                                                  ),
                                                  selectedColor: Colors.black,
                                                  cancelText: Text(
                                                    "Cancel",
                                                    style: Font_Styles
                                                        .labelHeadingRegular(
                                                            context),
                                                  ),
                                                  confirmText: Text(
                                                    "Ok",
                                                    style: Font_Styles
                                                        .labelHeadingRegular(
                                                            context),
                                                  ),
                                                  checkColor: Colors.white,
                                                  initialValue: controller
                                                              .selectedSubjects[
                                                          className] ??
                                                      [],
                                                  onConfirm: (results) {
                                                    print(results);

                                                    print(controller
                                                        .selectedSubjects);
                                                    controller.selectedSubjects
                                                        .remove(className);

                                                    controller.selectedSubjects[
                                                            className] =
                                                        results
                                                            .map((e) =>
                                                                e.toString())
                                                            .toList();
                                                    print(controller
                                                        .selectedSubjects);
                                                  },
                                                ),
                                              ),
                                          ],
                                        )),
                                  ],
                                );
                              }
                            }),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: Obx(() {
                              if (controller.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.appDarkBlue),
                                );
                              } else {
                                final filteredClasses = controller
                                    .classesSubjects
                                    .where((classSubject) => controller
                                        .selectedClasses
                                        .contains(classSubject.className))
                                    .map((classSubject) =>
                                        classSubject.className)
                                    .toList();

                                final items = [
                                  const DropdownMenuItem<String>(
                                    value: '',
                                    child: Text('None'),
                                  ),
                                  ...filteredClasses.map(
                                      (className) => DropdownMenuItem<String>(
                                            value: className,
                                            child: Text(className),
                                          )),
                                ];

                                return DropdownButtonFormField<String>(
                                  value: items
                                          .map((item) => item.value)
                                          .contains(controller
                                              .existingClassTeacher.value)
                                      ? controller.existingClassTeacher.value
                                      : null,
                                  items: items,
                                  onChanged: (newValue) {
                                    controller.selectedClassTeacher.value =
                                        newValue ?? '';
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Class Teacher",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
