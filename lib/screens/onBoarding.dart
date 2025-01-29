import 'dart:async';
import 'package:classinsight/Widgets/PageTransitions.dart';
import 'package:classinsight/screens/LoginAs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Widgets/BaseScreen.dart';
import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:classinsight/Widgets/onBoardDropDown.dart';

class SchoolController extends GetxController {
  var schools = <School>[].obs;
  var school = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getSchools();
  }

  void getSchools() async {
    var fetchedSchools = await Database_Service.getAllSchools();
    schools.assignAll(fetchedSchools);
  }

  void setSchool(String value) {
    school.value = value;
  }

  String getSchool() {
    return school.value;
  }
}

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> with SingleTickerProviderStateMixin {
  final SchoolController schoolController = Get.put(SchoolController());
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Timer _timer;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _timer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _showDropdown = true;
        _animationController.forward();
      });
    });

    // Fetch schools data
    schoolController.getSchools();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: BaseScreen(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, 1),
                end: Offset(0, -0.2),
              ).animate(_animation),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      "Class Insight",
                      style: Font_Styles.largeHeadingBold(context),
                    ),
                    Text(
                      "A School Management System",
                      style: Font_Styles.labelHeadingLight(context),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            _showDropdown
                ? Obx(() {
                    if (schoolController.schools.isEmpty) {
                      return CircularProgressIndicator(); // Show a loading indicator while fetching data
                    } else {
                      return OnBoardDropDown(
                        items: schoolController.schools,
                        onChanged: (item) {
                          print("CLICKED" + item!.schoolId);
                          // Get.toNamed("/loginAs", arguments: item);
                          Go.to(() => LoginAs(), arguments: item);
                        },
                      );
                    }
                  })
                : Container(),
          ],
        ),
      ),
    );
  }
}
