// ignore_for_file: prefer_const_constructors

import 'package:classinsight/screens/adminSide/AdminHome.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:flutter/material.dart';


class AddSubject extends StatefulWidget {
  const AddSubject({super.key});

  @override
  State<AddSubject> createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {

  double addSubjectFontSize = 16;
  double headingFontSize = 33;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 350) {
      addSubjectFontSize = 14;
      headingFontSize = 25;
    }
    if (screenWidth < 300) {
      addSubjectFontSize = 14;
      headingFontSize = 23;
    }
    if (screenWidth < 250) {
      addSubjectFontSize = 11;
      headingFontSize = 20;
    }
    if (screenWidth < 230) {
      addSubjectFontSize = 8;
      headingFontSize = 17;
    }

    return Scaffold(
        backgroundColor: AppColors.appLightBlue,
        body:Container(
            height: screenHeight,
            width: screenWidth,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                height: screenHeight * 0.10,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: AppColors.appLightBlue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        'Edit Student',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: addSubjectFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: TextButton(
                        onPressed: () async {
                          // add firebase logic here
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminHome()),
                          );
                        },
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                  Expanded(
                    child: Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 4,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(

                      ),
                    ) 
                  )
                ],
              ),
            ),
          ),
    );
  }
}
