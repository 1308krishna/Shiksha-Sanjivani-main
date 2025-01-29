// ignore_for_file: unused_local_variable

import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/models/StudentModel.dart';
import 'package:classinsight/models/TeacherModel.dart';
import 'package:classinsight/utils/AppColors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';



class Auth_Service {
  
static FirebaseAuth auth = FirebaseAuth.instance;

static Future<void> loginAdmin(String email, String password, School school) async {

  try {
      print("HEREEE" + school.schoolId);
      if (school.adminEmail == email || email == 'teamclassinsight@gmail.com') {
        print("HWEFBHEBH"+school.schoolId);

        Get.snackbar('Logging In', '',
          backgroundColor: Colors.white, 
          showProgressIndicator: true,
          progressIndicatorBackgroundColor: AppColors.appDarkBlue
          );


        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Get.offAllNamed('/AdminHome', arguments: school);
        Get.snackbar('Logged in Successfully', "Welcome, Admin - ${school.name}",duration: Duration(seconds: 1));
        // print(userCredential);

        print("Logged IN");
      } else {
        // Email does not match
        Get.snackbar('Login Error', 'Email does not match the admin email for the school');
      }
    
  } on FirebaseAuthException catch (e) {
    // Handle authentication error
    Get.snackbar('Login Error', e.message ?? 'An error occurred');
  } catch (e) {
    // Handle other errors
    Get.snackbar('Error', e.toString());
  }
}


static Future<void> logout(BuildContext context) async {
    try {
      Get.snackbar('Logging out', '',
          backgroundColor: Colors.white, 
          showProgressIndicator: true,
          progressIndicatorBackgroundColor: AppColors.appDarkBlue
          );

      await Future.delayed(Duration(seconds: 2));

      await auth.signOut();

      Get.deleteAll();

      Get.snackbar('Logged out successfully!', '',
          backgroundColor: Colors.white, duration: Duration(seconds: 2));

      Get.offAllNamed("/onBoarding");
    } catch (e) {
      print('Error logging out: $e');
      Get.snackbar('Error logging out', e.toString(),
          backgroundColor: Colors.red, duration: Duration(seconds: 2));
    }
  }


  static Future<void> registerTeacher(String email, String password, String schoolId) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user?.uid ?? '';

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Registration Error', e.message ?? 'An error occurred');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }



static Future<void> loginTeacher(String email, String password, School school) async {
  try {

        Get.snackbar('Logging In', '',
        backgroundColor: Colors.white, 
        showProgressIndicator: true,
        progressIndicatorBackgroundColor: AppColors.appDarkBlue);

    CollectionReference schoolsRef = FirebaseFirestore.instance.collection('Schools');

    QuerySnapshot schoolSnapshot = await schoolsRef.where('SchoolID', isEqualTo: school.schoolId).get();

    if (schoolSnapshot.docs.isEmpty) {
      Get.snackbar('Error', 'School with ID ${school.schoolId} not found');
      return;
    }

    DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;
    CollectionReference teachersRef = schoolDocRef.collection('Teachers');

    QuerySnapshot teacherSnapshot = await teachersRef.where('Email', isEqualTo: email).get();

    print(teacherSnapshot.docs);

    if (teacherSnapshot.docs.isEmpty) {
      Get.snackbar('Error', 'No teacher found with this email');
      return;
    }

  

    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    
    if (userCredential.user != null) {
      DocumentSnapshot teacherDoc = teacherSnapshot.docs.first;
      Map<String, dynamic> data = teacherDoc.data() as Map<String, dynamic>;

      Teacher teacher = Teacher(
        empID: data['EmployeeID'],
        name: data['Name'],
        gender: data['Gender'],
        email: data['Email'],
        cnic: data['CNIC'],
        phoneNo: data['PhoneNo'],
        fatherName: data['FatherName'],
        classes: List<String>.from(data['Classes'] ?? []),
        subjects: (data['Subjects'] as Map<String, dynamic>).map((key, value) {
          return MapEntry(key, List<String>.from(value));
        }),
        classTeacher: data['ClassTeacher'],
        
      );

      print('Hi ${teacher.email}');

      

      Get.snackbar('Success', 'Login successful');

      Get.offAllNamed('/TeacherDashboard', arguments: [teacher,school]);
    }
  } catch (e) {
    Get.snackbar('Error', 'Email or password incorrect');
  }
}


static Future<void> sendPasswordEmail(String teacherEmail, String teacherName, String password) async {
    final smtpServer = gmail('GOOGLE_EMAIL'!,'GOOGLE_PASSWORD');

    final message = Message()
      ..from = Address('GOOGLE_EMAIL'!, 'Class Insight')
      ..recipients.add(teacherEmail)
      ..subject = 'Login Credentials for Class Insight'
      ..text = 'Hi $teacherName,\n\nWelcome to Class Insight 😀. Please use the following password to log in to your Teacher Dashboard:\n\nPassword: $password\n\nBest Regards,\nClass Insight Team';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    } catch (e) {
      print('An unexpected error occurred: $e');
    }
  }



  static Future<void> loginParent(School school, String challanIDbForm) async {
    try {
      Get.snackbar('Logging In', '',
          backgroundColor: Colors.white, 
          showProgressIndicator: true,
          progressIndicatorBackgroundColor: AppColors.appDarkBlue
          );

      CollectionReference schoolsRef = FirebaseFirestore.instance.collection('Schools');

      QuerySnapshot schoolSnapshot = await schoolsRef.where('SchoolID', isEqualTo: school.schoolId).get();

      if (schoolSnapshot.docs.isEmpty) {
        Get.snackbar('Error', 'School with ID ${school.schoolId} not found');
        return;
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;
      CollectionReference studentsRef = schoolDocRef.collection('Students');

      QuerySnapshot studentSnapshot = await studentsRef.where('BForm_challanId', isEqualTo: challanIDbForm).get();

      if (studentSnapshot.docs.isEmpty) {
        Get.snackbar('Error', 'No student found with this Challan ID');
        return;
      }

      DocumentSnapshot studentDoc = studentSnapshot.docs.first;
      Map<String, dynamic> data = studentDoc.data() as Map<String, dynamic>;

      Student student = Student.fromJson(data);

        Get.snackbar('Success', 'Login successful');
        Get.offAllNamed('/ParentDashboard', arguments: [student,school]);
      
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
    }
  }


}