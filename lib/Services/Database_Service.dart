import 'package:classinsight/models/AnnouncementsModel.dart';
import 'package:classinsight/models/ClassModel.dart';
import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/models/TeacherModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classinsight/models/StudentModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Database_Service extends GetxService {
  // Future<void> saveStudent(
  //     String schoolID, String classSection, Student student) async {
  //   try {
  //     CollectionReference studentsRef = FirebaseFirestore.instance
  //         .collection('schools')
  //         .doc(schoolID)
  //         .collection('Students');

  //     DocumentReference studentDoc = await studentsRef.add(student.toMap());
  //     student.studentID = studentDoc.id;
  //     await studentDoc.update({
  //       'StudentID': student.studentID,
  //     });

  //     List<String> subjects = await fetchSubjects(schoolID, classSection);

  //     List<String> examTypes = await fetchExamStructure(schoolID, classSection);

  //     Map<String, Map<String, dynamic>> resultMap = {};
  //     for (String subject in subjects) {
  //       resultMap[subject] = {};
  //       for (String examType in examTypes) {
  //         resultMap[subject]![examType] = '-';
  //       }
  //     }

  //     await studentDoc.update({'resultMap': resultMap});

  //     print('Student saved successfully with ID: ${student.studentID}');
  //   } catch (e) {
  //     print('Error saving student: $e');
  //   }
  // }
  Future<void> saveStudent(BuildContext? context, String schoolID,
      String classSection, Student student) async {
    try {
      CollectionReference studentsRef = FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolID)
          .collection('Students');

      String bFormChallanId = student.bFormChallanId;
      DocumentReference studentDoc = studentsRef.doc(bFormChallanId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot docSnapshot = await transaction.get(studentDoc);
        if (docSnapshot.exists) {
          ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
              content: Text('A student with the same B-Form already exists.')));
          return;
        }

        transaction.set(studentDoc, student.toMap());

        student.studentID = studentDoc.id;
        transaction.update(studentDoc, {
          'StudentID': student.studentID,
        });

        List<String> subjects = await fetchSubjects(schoolID, classSection);
        List<String> examTypes =
            await fetchExamStructure(schoolID, classSection);

        Map<String, Map<String, dynamic>> resultMap = {};
        for (String subject in subjects) {
          resultMap[subject] = {};
          for (String examType in examTypes) {
            resultMap[subject]![examType] = '-';
          }
        }

        transaction.update(studentDoc, {'resultMap': resultMap});
      });

      print('Student saved successfully with ID: ${student.studentID}');
    } catch (e) {
      print('Error saving student: $e');
      if (e.toString().contains(
          'A student with the same BForm_challanId already exists.')) {
        ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
            content: Text(
                'A student with the same BForm_challanId already exists.')));
      } else {
        ScaffoldMessenger.of(context!)
            .showSnackBar(SnackBar(content: Text('Error saving student: $e')));
      }
    }
  }

  Future<Map<String, Map<String, String>>> fetchStudentResultMap(
      String schoolID, String studentID) async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolID)
          .collection('Students')
          .doc(studentID)
          .get();

      if (studentDoc.exists) {
        Map<String, dynamic> resultMap = studentDoc['resultMap'];
        return resultMap.map(
            (key, value) => MapEntry(key, Map<String, String>.from(value)));
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching resultMap: $e');
      return {};
    }
  }

  // Future<Map<String, Map<String, String>>> fetchStudentResultMap(
  //     String schoolID, String studentID) async {
  //   try {
  //     DocumentSnapshot studentDoc = await FirebaseFirestore.instance
  //         .collection('schools')
  //         .doc(schoolID)
  //         .collection('Students')
  //         .doc(studentID)
  //         .get();

  //     if (studentDoc.exists) {
  //       Map<String, dynamic> resultMap = studentDoc['resultMap'];
  //       return resultMap.map((subject, exams) {
  //         Map<String, String> processedExams =
  //             Map<String, String>.from(exams).map((examType, marks) {
  //           String obtainedMarks = '-';
  //           if (marks is String) {
  //             RegExp regex = RegExp(r'^(\d+)/\d+$');
  //             Match? match = regex.firstMatch(marks);
  //             if (match != null) {
  //               obtainedMarks = match.group(1) ?? '-';
  //             }
  //           }
  //           return MapEntry(examType, obtainedMarks);
  //         });
  //         return MapEntry(subject, processedExams);
  //       });
  //     } else {
  //       return {};
  //     }
  //   } catch (e) {
  //     print('Error fetching resultMap: $e');
  //     return {};
  //   }
  // }

  Future<void> updateOrAddMarks(String schoolID, String studentID,
      String subject, String examType, String obtainedMarks) async {
    try {
      DocumentReference studentDocRef = FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolID)
          .collection('Students')
          .doc(studentID);

      DocumentSnapshot studentDoc = await studentDocRef.get();

      if (studentDoc.exists) {
        Map<String, dynamic> resultMap = studentDoc['resultMap'] ?? {};

        if (!resultMap.containsKey(subject)) {
          resultMap[subject] = {};
        }

        resultMap[subject][examType] = obtainedMarks;

        await studentDocRef.update({'resultMap': resultMap});

        print('Marks updated successfully.');
      } else {
        print('Student document does not exist.');
      }
    } catch (e) {
      print('Error updating or adding marks: $e');
    }
  }

  Future<List<String>> fetchExamStructure(
      String schoolID, String className) async {
    try {
      QuerySnapshot classQuery = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolID)
          .collection('Classes')
          .where('className', isEqualTo: className)
          .get();

      if (classQuery.size > 0) {
        DocumentSnapshot classDoc = classQuery.docs.first;

        List<dynamic>? examTypes = classDoc.get('examTypes');

        if (examTypes != null) {
          List<String> examTypesList = examTypes.cast<String>();
          return examTypesList;
        } else {
          print(
              'Exam types not found or invalid format for class $className in school $schoolID.');
          return [];
        }
      } else {
        print('Class document not found for $className in school $schoolID.');
        return [];
      }
    } catch (e) {
      print('Error fetching exam types: $e');
      return [];
    }
  }

  static Future<List<Student>> getAllStudents(String schoolId) async {
    List<Student> students = [];
    try {
      QuerySnapshot schoolQuery = await FirebaseFirestore.instance
          .collection('schools')
          .where('SchoolID', isEqualTo: schoolId)
          .get();

      if (schoolQuery.docs.isEmpty) {
        return students;
      }

      String schoolDocId = schoolQuery.docs.first.id;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolDocId)
          .collection('Students')
          .get();

      for (var doc in querySnapshot.docs) {
        students.add(Student.fromJson(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print('Error getting students: $e');
    }
    return students;
  }

  static Future<List<Student>> getStudentsOfASpecificClass(
      String school, String classSection) async {
    List<Student> students = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('Students')
          .where('ClassSection', isEqualTo: classSection)
          .get();

      for (var doc in querySnapshot.docs) {
        students.add(Student.fromJson(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print('Error getting students: $e');
    }
    return students;
  }

  static Future<void> updateFeeStatus(String schoolId, String studentID,
      String feeStatus, String startDate, String endDate) async {
    var studentDoc = FirebaseFirestore.instance
        .collection('schools')
        .doc(schoolId) // Ensure schoolId is provided
        .collection('Students')
        .doc(studentID);

    await studentDoc.update({
      'FeeStatus': feeStatus,
      'FeeStartDate': startDate,
      'FeeEndDate': endDate,
    });
  }

  static Future<List<String>> fetchClasses(String schoolId) async {
    try {
      QuerySnapshot schoolQuery = await FirebaseFirestore.instance
          .collection('schools')
          .where('SchoolID', isEqualTo: schoolId)
          .get();

      if (schoolQuery.docs.isEmpty) {
        return [];
      }

      String schoolDocId = schoolQuery.docs.first.id;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolDocId)
          .collection('Classes')
          .get();

      List<String> classes =
          querySnapshot.docs.map((doc) => doc['className'] as String).toList();
      return classes;
    } catch (e) {
      print('Error fetching classes: $e');
      return [];
    }
  }

  static Future<List<String>> fetchSubjects(
      String schoolId, String className) async {
    try {
      QuerySnapshot schoolQuery = await FirebaseFirestore.instance
          .collection('schools')
          .where('SchoolID', isEqualTo: schoolId)
          .get();

      if (schoolQuery.docs.isEmpty) {
        return [];
      }

      String schoolDocId = schoolQuery.docs.first.id;

      QuerySnapshot classQuery = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolDocId)
          .collection('Classes')
          .where('className', isEqualTo: className)
          .get();

      if (classQuery.docs.isEmpty) {
        return [];
      }

      DocumentSnapshot classDoc = classQuery.docs.first;
      Map<String, dynamic>? classData =
          classDoc.data() as Map<String, dynamic>?;

      if (classData != null && classData.containsKey('subjects')) {
        List<dynamic> subjectsDynamic = classData['subjects'];
        List<String> subjects =
            subjectsDynamic.map((subject) => subject.toString()).toList();
        return subjects;
      } else {
        print('No subjects field found in class document');
        return [];
      }
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  static Future<Map<String, List<String>>> fetchClassesAndSubjects(
      String schoolId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolId)
          .collection('Classes')
          .get();

      Map<String, List<String>> classesAndSubjects = {};

      for (var doc in querySnapshot.docs) {
        String className = doc['className'] as String;
        List<String> subjects = List<String>.from(doc['subjects'] ?? []);
        classesAndSubjects[className] = subjects;
      }

      return classesAndSubjects;
    } catch (e) {
      print('Error fetching classes and subjects: $e');
      return {};
    }
  }

  static Future<void> saveTeacher(
    String schoolID,
    String empID,
    String name,
    String gender,
    String email,
    String phoneNo,
    String cnic,
    String fatherName,
    List<String> classes,
    Map<String, List<String>> subjects,
    String classTeacher,
  ) async {
    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolID', isEqualTo: schoolID).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with ID $schoolID not found');
        return;
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;

      CollectionReference teacherRef = schoolDocRef.collection('Teachers');

      await teacherRef.add({
        'EmployeeID': empID,
        'Name': name,
        'Gender': gender,
        'Email': email,
        'PhoneNo': phoneNo,
        'CNIC': cnic,
        'FatherName': fatherName,
        'Classes': classes,
        'Subjects': subjects,
        'ClassTeacher': classTeacher,
      });

      Get.back(result: 'updated');

      print('Teacher saved successfully');
    } catch (e) {
      print('Error saving teacher: $e');
    }
  }

  static Future<List<Teacher>> fetchTeachers(String schoolID) async {
    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolID', isEqualTo: schoolID).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with ID $schoolID not found');
        return [];
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;

      CollectionReference teachersRef = schoolDocRef.collection('Teachers');

      QuerySnapshot teachersSnapshot = await teachersRef.get();

      List<Teacher> teachers = teachersSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Teacher(
          empID: data['EmployeeID'],
          name: data['Name'],
          gender: data['Gender'],
          email: data['Email'],
          cnic: data['CNIC'],
          phoneNo: data['PhoneNo'],
          fatherName: data['FatherName'],
          classes: List<String>.from(data['Classes'] ?? []),
          subjects:
              (data['Subjects'] as Map<String, dynamic>).map((key, value) {
            return MapEntry(key, List<String>.from(value));
          }),
          classTeacher: data['ClassTeacher'],
        );
      }).toList();

      return teachers;
    } catch (e) {
      print('Error fetching teachers: $e');
      return [];
    }
  }

  static Future<void> deleteTeacher(String schoolID, String empID) async {
    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolID', isEqualTo: schoolID).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with ID $schoolID not found');
        return;
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;

      CollectionReference teachersRef = schoolDocRef.collection('Teachers');

      QuerySnapshot teacherSnapshot =
          await teachersRef.where('EmployeeID', isEqualTo: empID).get();

      if (teacherSnapshot.docs.isEmpty) {
        print('Teacher with EmployeeID $empID not found');
        return;
      }

      DocumentSnapshot teacherDoc = teacherSnapshot.docs.first;

      await teacherDoc.reference.delete();

      print('Teacher with EmployeeID $empID deleted successfully');
    } catch (e) {
      print('Error deleting teacher: $e');
    }
  }

  static Future<List<Teacher>> searchTeachersByName(
      String schoolID, String searchText) async {
    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolID', isEqualTo: schoolID).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with ID $schoolID not found');
        return [];
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;
      CollectionReference teachersRef = schoolDocRef.collection('Teachers');

      QuerySnapshot teachersSnapshot = await teachersRef.get();

      List<Teacher> allTeachers = teachersSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Teacher(
          empID: data['EmployeeID'],
          name: data['Name'],
          gender: data['Gender'],
          email: data['Email'],
          cnic: data['CNIC'],
          phoneNo: data['PhoneNo'],
          fatherName: data['FatherName'],
          classes: List<String>.from(data['Classes'] ?? []),
          subjects:
              (data['Subjects'] as Map<String, dynamic>).map((key, value) {
            return MapEntry(key, List<String>.from(value));
          }),
          classTeacher: data['ClassTeacher'],
        );
      }).toList();

      List<Teacher> filteredTeachers = allTeachers.where((teacher) {
        return teacher.name.contains(searchText);
      }).toList();

      print('Teachers found: ${filteredTeachers.length}');

      return filteredTeachers;
    } catch (e) {
      print('Error searching teachers: $e');
      return [];
    }
  }

  static Future<List<Teacher>> searchTeachersByEmployeeID(
      String schoolID, String employeeID) async {
    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolID', isEqualTo: schoolID).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with ID $schoolID not found');
        return [];
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;
      CollectionReference teachersRef = schoolDocRef.collection('Teachers');

      QuerySnapshot teachersSnapshot;

      if (employeeID.isNotEmpty) {
        teachersSnapshot =
            await teachersRef.where('EmployeeID', isEqualTo: employeeID).get();
      } else {
        teachersSnapshot = await teachersRef.get();
      }

      List<Teacher> teachers = teachersSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Teacher(
          empID: data['EmployeeID'],
          name: data['Name'],
          gender: data['Gender'],
          email: data['Email'],
          cnic: data['CNIC'],
          phoneNo: data['PhoneNo'],
          fatherName: data['FatherName'],
          classes: List<String>.from(data['Classes'] ?? []),
          subjects:
              (data['Subjects'] as Map<String, dynamic>).map((key, value) {
            return MapEntry(key, List<String>.from(value));
          }),
          classTeacher: data['ClassTeacher'],
        );
      }).toList();

      print('Teachers found: ${teachers.length}');

      return teachers;
    } catch (e) {
      print('Error searching teachers: $e');
      return [];
    }
  }

  static Future<void> deleteClassByName(
      String schoolName, String className) async {
    try {
      QuerySnapshot schoolQuery = await FirebaseFirestore.instance
          .collection('schools')
          .where('SchoolName', isEqualTo: schoolName)
          .get();

      if (schoolQuery.docs.isEmpty) {
        print('School not found with name: $schoolName');
        return;
      }

      String schoolId = schoolQuery.docs.first.id;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolId)
          .collection('Classes')
          .where('className', isEqualTo: className)
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('Successfully deleted class documents with className: $className');
    } catch (e) {
      print("Error deleting class: $e");
    }
  }

  static Future<String> fetchCounts(
      String schoolName, String collectionName) async {
    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolName', isEqualTo: schoolName).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with name $schoolName not found');
        return "0";
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;

      CollectionReference teachersRef = schoolDocRef.collection(collectionName);

      QuerySnapshot teachersSnapshot = await teachersRef.limit(1).get();

      if (teachersSnapshot.docs.isEmpty) {
        return "0";
      } else {
        QuerySnapshot fullSnapshot = await teachersRef.get();
        return fullSnapshot.size.toString();
      }
    } catch (e) {
      print('Error fetching count from collection $collectionName: $e');
      return "0";
    }
  }

  static Future<void> updateTeacher(
    String schoolID,
    String empID,
    String name,
    String gender,
    String email,
    String phoneNo,
    String cnic,
    String fatherName,
    List<String> classes,
    Map<String, List<String>> subjects,
    String classTeacher,
  ) async {
    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolID', isEqualTo: schoolID).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with ID $schoolID not found');
        return;
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;

      CollectionReference teachersRef = schoolDocRef.collection('Teachers');

      QuerySnapshot teacherSnapshot =
          await teachersRef.where('EmployeeID', isEqualTo: empID).get();

      if (teacherSnapshot.docs.isEmpty) {
        print('Teacher with EmployeeID $empID not found');
        return;
      }

      DocumentReference teacherDocRef = teacherSnapshot.docs.first.reference;

      await teacherDocRef.update({
        'Name': name,
        'Gender': gender,
        'Email': email,
        'PhoneNo': phoneNo,
        'CNIC': cnic,
        'FatherName': fatherName,
        'Classes': classes,
        'Subjects': subjects,
        'ClassTeacher': classTeacher,
      });

      print('Teacher updated successfully');
    } catch (e) {
      print('Error updating teacher: $e');
    }
  }

  static Future<List<Student>> searchStudentsByRollNo(
      String school, String classSection, String rollNo) async {
    List<Student> students = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('Students')
          .where('ClassSection', isEqualTo: classSection)
          .where('StudentRollNo', isEqualTo: rollNo)
          .get();

      for (var doc in querySnapshot.docs) {
        students.add(Student.fromJson(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {}
    return students;
  }

  static Future<List<Student>> searchStudentsByName(
      String school, String classSection, String studentName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('Students')
          .where('ClassSection', isEqualTo: classSection)
          .get();

      List<Student> allStudents = querySnapshot.docs.map((doc) {
        return Student.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      List<Student> filteredStudents = allStudents.where((student) {
        return student.name.toLowerCase().contains(studentName.toLowerCase());
      }).toList();

      return filteredStudents;
    } catch (e) {
      print(
          'Error searching students by name $studentName in class $classSection: $e');
      return [];
    }
  }

  static Future<Student?> getStudentByID(
      String school, String studentID) async {
    Student? student;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('Students')
          .where('StudentID', isEqualTo: studentID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        student = Student.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        print('Student not found for ID: $studentID');
      }
    } catch (e) {
      print('Error searching students by ID $studentID: $e');
    }
    return student;
  }

  static Future<void> updateStudent(
      String school, String studentID, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('schools')
          .doc(school)
          .collection('Students')
          .doc(studentID)
          .update(data);
      print('Student updated successfully');
    } catch (e) {
      print('Error updating student: $e');
    }
  }

  static Future<void> deleteStudent(String schoolID, String studentID) async {
    try {
      DocumentReference studentRef = FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolID)
          .collection('Students')
          .doc(studentID);

      await studentRef.delete();
      print('Student deleted successfully');
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  static Future<List<School>> getAllSchools() async {
    List<School> schools = [];
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('schools').get();

      for (var doc in querySnapshot.docs) {
        schools.add(School.fromJson(doc.data() as Map<String, dynamic>));
        print(doc.data());
      }
    } catch (e) {
      print('Error getting schools: $e');
    }
    return schools;
  }

  static Future<void> addClass(
      List<String>? classes,
      List<String>? subjects,
      List<String> examSystem,
      Map<String, String> weightage,
      String schoolID) async {
    try {
      QuerySnapshot schoolSnapshot = await FirebaseFirestore.instance
          .collection('schools')
          .where('SchoolID', isEqualTo: schoolID)
          .get();

      if (schoolSnapshot.docs.isNotEmpty) {
        DocumentReference schoolDoc = schoolSnapshot.docs.first.reference;
        CollectionReference classesCollection = schoolDoc.collection('Classes');

        for (String className in classes ?? []) {
          DocumentReference classDoc = classesCollection.doc(className);

          Class newClass = Class(
            classId: className,
            className: className,
            timetable: false,
            subjects: subjects ?? [],
            examTypes: examSystem,
            weightage: weightage,
          );

          await classDoc.set(newClass.toJson());
        }

        print('Classes added successfully');
      } else {
        print('School document not found');
      }
    } catch (e) {
      print('Error adding classes: $e');
    }
  }

  static Future<List<String>> fetchAllClasses(String schoolID) async {
    List<String> classNames = [];
    try {
      CollectionReference classesRef = FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolID)
          .collection('Classes');
      QuerySnapshot querySnapshot = await classesRef.get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        classNames.add(doc['className']);
      }

      classNames.sort();
    } catch (e) {
      print('Error fetching classes: $e');
    }
    return classNames;
  }

  static Future<List<String>> fetchAllClassesbyTimetable(
      String schoolID, bool timetable) async {
    List<String> classNames = [];
    try {
      CollectionReference classesRef = FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolID)
          .collection('Classes');

      QuerySnapshot querySnapshot =
          await classesRef.where("timetable", isEqualTo: timetable).get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        classNames.add(doc['className']);
      }

      // Sort the class names lexicographically
      classNames.sort();
    } catch (e) {
      print('Error fetching classes: $e');
    }
    return classNames;
  }

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addTimetablebyClass(String schoolId, String className,
      String format, Map<String, Map<String, String>> timetable) async {
    try {
      CollectionReference timetableCollection = _firestore
          .collection('schools')
          .doc(schoolId)
          .collection('Timetable');
      CollectionReference classesCollection =
          _firestore.collection('schools').doc(schoolId).collection('Classes');

      QuerySnapshot querySnapshot = await classesCollection
          .where('className', isEqualTo: className)
          .get();

      // Save the timetable data
      await timetableCollection.doc(className).set({
        'className': className,
        'format': format,
        'timetable': timetable,
      });

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference classDocRef = querySnapshot.docs.first.reference;
        await classDocRef.update({
          'timetable': true,
        });
      }

      print('Timetable added successfully!');
    } catch (e) {
      print('Error adding timetable: $e');
      throw e;
    }
  }

  static Future<void> deleteTimetableByClass(
      String schoolId, String className) async {
    try {
      DocumentReference timetableRef = await _firestore
          .collection("Schools")
          .doc(schoolId)
          .collection("Timetable")
          .doc(className);
      CollectionReference classesCollection =
          _firestore.collection('schools').doc(schoolId).collection('Classes');

      DocumentSnapshot timetableSnapshot = await timetableRef.get();
      QuerySnapshot querySnapshot = await classesCollection
          .where('className', isEqualTo: className)
          .get();

      if (!timetableSnapshot.exists) {
        print("No timetable found for class: $className");
        return;
      }
      await timetableSnapshot.reference.delete();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference classDocRef = querySnapshot.docs.first.reference;
        await classDocRef.update({
          'timetable': false,
        });
      }
    } catch (e) {}
  }

  static Future<Map<String, dynamic>> fetchTimetable(
      String schoolId, String className, String day) async {
    try {
      print(
          "Fetching timetable for schoolId: $schoolId, className: $className");

      DocumentReference timetableDocRef = _firestore
          .collection("Schools")
          .doc(schoolId)
          .collection('Timetable')
          .doc(className);
      DocumentSnapshot timetableSnapshot = await timetableDocRef.get();

      if (!timetableSnapshot.exists) {
        print("No timetable found for class: $className");
        return {};
      }

      Map<String, dynamic>? timetableData =
          timetableSnapshot.data() as Map<String, dynamic>?;

      if (timetableData == null) {
        print("No data retrieved from the timetable document");
        return {};
      }

      if (!timetableData.containsKey('timetable')) {
        print("No 'timetable' field in the document");
        return {};
      }

      Map<String, dynamic> timetable =
          timetableData['timetable'] as Map<String, dynamic>;
      Map<String, dynamic> timetablebyDay = timetable[day];
      print(timetablebyDay);
      return timetablebyDay;
    } catch (e) {
      print("Error fetching timetable: $e");
      return {};
    }
  }

  static Future<void> createAnnouncement(
    String schoolID,
    String studentID,
    String announcementDescription,
    String announcementBy,
    bool adminAnnouncement,
  ) async {
    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolID', isEqualTo: schoolID).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with ID $schoolID not found');
        return;
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;
      CollectionReference announcementsRef =
          schoolDocRef.collection('Announcements');

      Announcement newAnnouncement = Announcement(
        announcementBy: announcementBy,
        announcementDate: Timestamp.now(),
        announcementDescription: announcementDescription,
        studentID: studentID,
        adminAnnouncement: adminAnnouncement,
      );

      await announcementsRef.add(newAnnouncement.toJson());

      print('Announcement saved successfully');
    } catch (e) {
      print('Error saving announcement: $e');
    }
  }

  static Future<void> updateAttendance(String schoolId,
      Map<String, String> studentStatusMap, String day, String subject) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      studentStatusMap.forEach((studentId, status) {
        DocumentReference studentRef = FirebaseFirestore.instance
            .collection('schools')
            .doc(schoolId)
            .collection('Students')
            .doc(studentId);

        batch.update(studentRef, {'attendance.$subject.$day': status});
      });

      await batch.commit();

      Get.back();
      Get.snackbar('Attendance submitted', 'Date: $day, Subject: $subject');
      print('Attendance updated successfully for all students');
    } catch (e) {
      print('Error updating attendance in bulk: $e');
    }
  }

  static Future<List<Announcement>?> fetchAdminAnnouncements(
      String schoolID) async {
    print('Fetching admin announcements');
    DateTime now = DateTime.now();

    DateTime sevendaysAgo = now.subtract(Duration(days: 7));

    Timestamp sevendaysTime = Timestamp.fromDate(sevendaysAgo);

    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolID', isEqualTo: schoolID).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with ID $schoolID not found');
        return null;
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;
      CollectionReference announcementsRef =
          schoolDocRef.collection('Announcements');

      QuerySnapshot announcementsSnapshot = await announcementsRef
          .where('AnnouncementBy', isEqualTo: 'Admin')
          .where('AnnouncementDate', isGreaterThanOrEqualTo: sevendaysTime)
          .get();

      List<Announcement> announcements = announcementsSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Announcement(
          announcementBy: data['AnnouncementBy'],
          announcementDate: data['AnnouncementDate'],
          announcementDescription: data['AnnouncementDescription'],
          studentID: data['StudentID'],
          adminAnnouncement: data['AdminAnnouncement'],
        );
      }).toList();

      print('Admin Announcements found: ${announcements.length}');

      return announcements;
    } catch (e) {
      print('Error fetching announcements: $e');
    }
    return null;
  }

  static Future<List<Announcement>?> fetchStudentAnnouncements(
      String schoolID, String studentID) async {
    DateTime now = DateTime.now();

    DateTime sevendaysAgo = now.subtract(Duration(days: 7));

    Timestamp sevendaysTime = Timestamp.fromDate(sevendaysAgo);
    try {
      CollectionReference schoolsRef =
          FirebaseFirestore.instance.collection('schools');

      QuerySnapshot schoolSnapshot =
          await schoolsRef.where('SchoolID', isEqualTo: schoolID).get();

      if (schoolSnapshot.docs.isEmpty) {
        print('School with ID $schoolID not found');
        return null;
      }

      DocumentReference schoolDocRef = schoolSnapshot.docs.first.reference;
      CollectionReference announcementsRef =
          schoolDocRef.collection('Announcements');

      QuerySnapshot announcementsSnapshot = await announcementsRef
          .where('StudentID', isEqualTo: studentID)
          .where('AnnouncementDate', isGreaterThanOrEqualTo: sevendaysTime)
          .get();

      List<Announcement> announcements = announcementsSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Announcement(
          announcementBy: data['AnnouncementBy'],
          announcementDate: data['AnnouncementDate'],
          announcementDescription: data['AnnouncementDescription'],
          studentID: data['StudentID'],
          adminAnnouncement: data['AdminAnnouncement'],
        );
      }).toList();

      print('Student Announcements found: ${announcements.length}');

      return announcements;
    } catch (e) {
      print('Error fetching announcements: $e');
    }
    return null;
  }

  Future<List<String>> fetchUniqueSubjects(
      String schoolId, String employeeId, String className) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<String> uniqueSubjects = [];

    try {
      QuerySnapshot teacherSnapshot = await firestore
          .collection('schools')
          .doc(schoolId)
          .collection('Teachers')
          .where('EmployeeID', isEqualTo: employeeId)
          .get();

      if (teacherSnapshot.docs.isNotEmpty) {
        DocumentSnapshot teacherDoc = teacherSnapshot.docs.first;

        Map<String, dynamic>? data = teacherDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          Map<String, dynamic>? subjectsMap =
              data['Subjects'] as Map<String, dynamic>?;

          if (subjectsMap != null && subjectsMap.containsKey(className)) {
            List<dynamic> subjectsList =
                subjectsMap[className] as List<dynamic>;
            uniqueSubjects =
                subjectsList.map((subject) => subject.toString()).toList();
            uniqueSubjects.sort();
          } else {
            print('No subjects found for the class $className.');
          }
        }
      } else {
        print('No teacher document found with the given EmployeeID.');
      }
    } catch (e) {
      print('Error fetching subjects: $e');
    }

    return uniqueSubjects;
  }

  // Method to fetch weightage for the exams
  Future<Map<String, String>> fetchWeightage(
      String schoolId, String classSection) async {
    try {
      // Get the document that contains the weightage field
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('schools')
          .doc(schoolId)
          .collection('Classes')
          .doc(classSection)
          .get();

      if (doc.exists) {
        // Extract the weightage map from the document
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('weightage')) {
          // Convert the weightage map to Map<String, String>
          Map<String, dynamic> weightageMap =
              data['weightage'] as Map<String, dynamic>;
              print(weightageMap);
          return weightageMap
              .map((key, value) => MapEntry(key, value.toString()));
        } else {
          print('No weightage field found in class section: $classSection');
          return {};
        }
      } else {
        print(
            'No document found for school ID: $schoolId and class section: $classSection');
        return {};
      }
    } catch (e) {
      print('Error fetching weightage: $e');
      return {};
    }
  }
}
