// ignore_for_file: must_be_immutable
import 'dart:math';
import 'package:classinsight/Services/Auth_Service.dart';
import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/Widgets/CustomBlueButton.dart';
import 'package:classinsight/Widgets/CustomTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddTeacherController extends GetxController {
  TextEditingController empIDController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cnicController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController fatherNameController = TextEditingController();

  var empIDValid = true.obs;
  var nameValid = true.obs;
  var emailValid = true.obs;
  var genderValid = true.obs;
  var cnicValid = true.obs;
  var fatherNameValid = true.obs;
  var phoneNoValid = true.obs;

  var selectedGender = ''.obs;
  var selectedClass = ''.obs;
  var selectedClassTeacher = ''.obs;
  var addStdFontSize = 16.0;
  var headingFontSize = 33.0;

  late School school;
  RxList<String> selectedClasses = <String>[].obs;
  RxList<ClassSubject> classesSubjects = <ClassSubject>[].obs;
  RxMap<String, List<String>> selectedSubjects = <String, List<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    school = Get.arguments as School;
    fetchClassesAndSubjects();
  }

  void fetchClassesAndSubjects() async {
    try {
      Map<String, List<String>> classesAndSubjectsMap =
          await Database_Service.fetchClassesAndSubjects(school.schoolId);

      List<ClassSubject> fetchedClassesSubjects = [];

      classesAndSubjectsMap.forEach((className, subjects) {
        print('Fetched subjects for class $className');
        fetchedClassesSubjects
            .add(ClassSubject(className: className, subjects: subjects));
      });

      classesSubjects.assignAll(fetchedClassesSubjects);
    } catch (e) {
      print('Error fetching classes and subjects: $e');
    }
  }

  bool validatePhoneNo(String phoneNo) {
    final RegExp phoneNoRegex = RegExp(r'^\d{11}$');
    return phoneNoRegex.hasMatch(phoneNo);
  }

  bool validateCnic(String cnic) {
    final RegExp cnicRegex = RegExp(r'^\d{13}$');
    return cnicRegex.hasMatch(cnic);
  }

  bool validateForm() {
    empIDValid.value = empIDController.text.isNotEmpty;
    nameValid.value = nameController.text.isNotEmpty;
    emailValid.value = emailController.text.isNotEmpty && GetUtils.isEmail(emailController.text);
    cnicValid.value = validateCnic(cnicController.text);
    phoneNoValid.value = validatePhoneNo(phoneNoController.text);
    fatherNameValid.value = fatherNameController.text.isNotEmpty;
    genderValid.value = selectedGender.value.isNotEmpty;

    return empIDValid.value && nameValid.value && emailValid.value && cnicValid.value && phoneNoValid.value && fatherNameValid.value && genderValid.value;
  }

  String capitalizeName(String name) {
    List<String> parts = name.split(' ');
    return parts.map((part) => _capitalize(part)).join(' ');
  }

  String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }
}


class ClassSubject {
  String className;
  List<String> subjects;

  ClassSubject({required this.className, required this.subjects});
}

class AddTeacher extends StatelessWidget {
  final AddTeacherController controller = Get.put(AddTeacherController());
  double addStdFontSize = 16;
  double headingFontSize = 33;

  AddTeacher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 350) {
      addStdFontSize = 14;
      headingFontSize = 25;
    }
    if (screenWidth < 300) {
      addStdFontSize = 14;
      headingFontSize = 23;
    }
    if (screenWidth < 250) {
      addStdFontSize = 11;
      headingFontSize = 20;
    }
    if (screenWidth < 230) {
      addStdFontSize = 8;
      headingFontSize = 17;
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
                    elevation: 0,
                    title: Center(
                      child: Text(
                        'Add Teacher',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: addStdFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      Container(
                        width: 48.0,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.05 * screenHeight,
                  width: screenWidth,
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Add New Teacher',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: headingFontSize,
                      fontWeight: FontWeight.w700,
                    ),
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
                      padding: EdgeInsets.only(bottom: keyboardHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
                            child: CustomTextField(
                              controller: controller.empIDController,
                              hintText: 'Employee ID',
                              labelText: 'Employee ID',
                              isValid: controller.empIDValid.value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: CustomTextField(
                              controller: controller.nameController,
                              hintText: 'Name',
                              labelText: 'Name',
                              isValid: controller.nameValid.value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.white,
                              ),
                              child: Obx(() => DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      hintText: "Select your gender",
                                      labelText: "Gender",
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: AppColors.appLightBlue,
                                            width: 2.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 1.0),
                                      ),
                                    ),
                                    value:
                                        controller.selectedGender.value.isEmpty
                                            ? null
                                            : controller.selectedGender.value,
                                    onChanged: (newValue) {
                                      controller.selectedGender.value =
                                          newValue!;
                                    },
                                    items: <String>['Male', 'Female', 'Other']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  )),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: CustomTextField(
                              controller: controller.emailController,
                              hintText: 'johndoe@....com',
                              labelText: 'Email',
                              isValid: controller.emailValid.value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: CustomTextField(
                              controller: controller.cnicController,
                              hintText: '35202xxxxxx78',
                              labelText: 'CNIC No',
                              isValid: controller.cnicValid.value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: CustomTextField(
                              controller: controller.phoneNoController,
                              hintText: '0321xxxxx12',
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
                            child: Obx(() => MultiSelectDialogField(
                                  backgroundColor: AppColors.appLightBlue,
                                  items: controller.classesSubjects
                                      .map((classSubject) => MultiSelectItem(
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
                                  buttonText: const Text(
                                    "Class to Assign",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  checkColor: Colors.white,
                                  cancelText: const Text(
                                    "CANCEL",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  confirmText: const Text(
                                    "OK",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onConfirm: (results) {
                                    controller.selectedClasses
                                        .assignAll(results);
                                  },
                                )),
                          ),
                          Obx(() => Column(
                                children: [
                                  for (var className
                                      in controller.selectedClasses)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          30, 0, 30, 20),
                                      child: MultiSelectDialogField(
                                        backgroundColor: AppColors.appLightBlue,
                                        items: controller.classesSubjects
                                            .firstWhere((classSubject) =>
                                                classSubject.className ==
                                                className)
                                            .subjects
                                            .map((subject) => MultiSelectItem(
                                                subject, subject))
                                            .toList(),
                                        title: Text("Subjects for $className"),
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
                                          Icons.subject,
                                          color: Colors.black,
                                        ),
                                        buttonText: Text(
                                          "Select Subjects for $className",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        selectedColor: Colors.black,
                                        cancelText: const Text(
                                          "CANCEL",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        confirmText: const Text(
                                          "OK",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        checkColor: Colors.white,
                                        onConfirm: (results) {
                                          controller
                                                  .selectedSubjects[className] =
                                              results;
                                        },
                                      ),
                                    ),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                            child: Obx(() => DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    hintText: "Class Teacher",
                                    labelText:
                                        "Select Section For Class Teacher",
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
                                  value: controller
                                          .selectedClassTeacher.value.isEmpty
                                      ? null
                                      : controller.selectedClassTeacher.value,
                                  onChanged: (newValue) {
                                    controller.selectedClassTeacher.value =
                                        newValue!;
                                  },
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: '',
                                      child: Text('None'),
                                    ),
                                    ...controller.selectedClasses
                                        .map<DropdownMenuItem<String>>(
                                            (String className) {
                                      return DropdownMenuItem<String>(
                                        value: className,
                                        child: Text(className),
                                      );
                                    }).toList(),
                                  ],
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                            child: CustomBlueButton(
                              buttonText: 'Add',
                              onPressed: () async {
                                if (!controller.validateForm()) {
                                  Get.snackbar('Error', 'Please fill all the fields correctly');
                                } else {
                                  try {
                                    Get.dialog(
                                      Center(
                                        child: Container(
                                          color: Colors.white,
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.appLightBlue),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      barrierDismissible: false,
                                    );

                                    String capitalizedName = controller.capitalizeName(controller.nameController.text);
                                    String capitalizedFatherName = controller.capitalizeName(controller.fatherNameController.text);

                                    await Database_Service.saveTeacher(
                                      controller.school.schoolId,
                                      controller.empIDController.text,
                                      capitalizedName,
                                      controller.selectedGender.value,
                                      controller.emailController.text,
                                      controller.phoneNoController.text,
                                      controller.cnicController.text,
                                      capitalizedFatherName,
                                      controller.selectedClasses.toList(),
                                      controller.selectedSubjects.toJson(),
                                      controller.selectedClassTeacher.value,
                                    ).then((value) => Get.back(result: 'updated'));

                                    String password = generateRandomPassword();
                                    print('Generated password: $password');

                                    await Auth_Service.registerTeacher(controller.emailController.text, password, controller.school.schoolId);
                                    await Auth_Service.sendPasswordEmail(controller.emailController.text, capitalizedName, password);

                                    Navigator.pop(context);
                                    Get.snackbar('Saved', 'New teacher added successfully');
                                  } catch (e) {
                                  }
                                }
                              },
                              text: 'Add',
                            ),
                          )

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

String generateRandomPassword() {
  const int minPasswordLength = 10;
  const int maxPasswordLength = 12;
  const String digits = '0123456789';
  const String specialChar = '@';
  
  final Random random = Random();

  const String word = 'insight';

  int passwordLength = minPasswordLength + random.nextInt(maxPasswordLength - minPasswordLength + 1);
  int remainingLength = passwordLength - word.length - 1; // Subtract length of 'insight' and '@'

  String randomNumbers = List.generate(remainingLength,
          (_) => digits[random.nextInt(digits.length)])
      .join('');

  String password = '$word$specialChar$randomNumbers';

  print('Generated password: $password');

  return password;
}
