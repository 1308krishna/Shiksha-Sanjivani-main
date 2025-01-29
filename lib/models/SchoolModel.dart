import 'package:cloud_firestore/cloud_firestore.dart';

class School {
  final String name;
  final String schoolId;
  final String adminEmail;

  School({
    required this.name,
    required this.schoolId,
    required this.adminEmail,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      name: json['SchoolName'] ?? '',
      adminEmail: json['AdminEmail'] ?? '',
      schoolId: json['SchoolID'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SchoolName': name,
      'AdminEmail': adminEmail,
      'SchoolID': schoolId,
    };
  }

  factory School.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return School(
      name: data['SchoolName'] ?? '',
      adminEmail: data['AdminEmail'] ?? '',
      schoolId: data['SchoolID'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'SchoolName': name,
      'AdminEmail': adminEmail,
      'SchoolID': schoolId,
    };
  }
}
