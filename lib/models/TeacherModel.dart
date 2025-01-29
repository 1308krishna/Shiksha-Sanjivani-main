class Teacher {
  late String empID;
  late String name;
  late String gender;
  late String email;
  late String cnic;
  late String phoneNo;
  late String fatherName;
  late List<String> classes;
  late Map<String, List<String>> subjects;
  late String classTeacher;

  Teacher({
    required this.empID,
    required this.name,
    required this.gender,
    required this.email,
    required this.cnic,
    required this.phoneNo,
    required this.fatherName,
    required this.classes,
    required this.subjects,
    required this.classTeacher,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
  return Teacher(
    empID: json['EmployeeID'] ?? '',
    name: json['Name'] ?? '',
    gender: json['Gender'] ?? '',
    email: json['Email'] ?? '',
    cnic: json['CNIC'] ?? '',
    phoneNo: json['PhoneNo'] ?? '',
    fatherName: json['FatherName'] ?? '',
    classes: List<String>.from(json['Classes'] ?? []),
    subjects: (json['Subjects'] as Map<String, dynamic>).map(
      (key, value) {
        if (value is List) {
          return MapEntry(key, List<String>.from(value));
        } else {
          return MapEntry(key, []);
        }
      },
    ),
    classTeacher: json['ClassTeacher'] ?? '',
  );
}


  Map<String, dynamic> toJson() {
    return {
      'EmployeeID': empID,
      'Name': name,
      'Gender': gender,
      'Email': email,
      'CNIC': cnic,
      'PhoneNo': phoneNo,
      'FatherName': fatherName,
      'Classes': classes,
      'Subjects': subjects,
      'ClassTeacher': classTeacher,
    };
  }
}
