class Student {
  late String name;
  late String gender;
  late String bFormChallanId;
  late String fatherName;
  late String fatherPhoneNo;
  late String fatherCNIC;
  late String studentRollNo;
  late String studentID;
  late String classSection;
  late String feeStatus;
  late String feeStartDate;
  late String feeEndDate;
  late Map<String, Map<String, String>> resultMap;
  late Map<String, Map<String, String>> attendance; 

  Student({
    required this.name,
    required this.gender,
    required this.bFormChallanId,
    required this.fatherName,
    required this.fatherPhoneNo,
    required this.fatherCNIC,
    required this.studentRollNo,
    required this.studentID,
    required this.classSection,
    required this.feeStatus,
    required this.feeStartDate,
    required this.feeEndDate,
    Map<String, Map<String, String>>? resultMap,
    Map<String, Map<String, String>>? attendance, 
  }) : 
  resultMap = resultMap ?? {},
  attendance = attendance ?? {}; 

  factory Student.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, String>> parseNestedMap(dynamic map) {
      if (map == null) return {};
      return Map<String, Map<String, String>>.from(
        map.map((key, value) => MapEntry(
          key,
          Map<String, String>.from(value),
        ))
      );
    }

    return Student(
      name: json['Name'] ?? '',
      gender: json['Gender'] ?? '',
      bFormChallanId: json['BForm_challanId'] ?? '',
      fatherName: json['FatherName'] ?? '',
      fatherPhoneNo: json['FatherPhoneNo'] ?? '',
      fatherCNIC: json['FatherCNIC'] ?? '',
      studentRollNo: json['StudentRollNo'] ?? '',
      studentID: json['StudentID'] ?? '',
      classSection: json['ClassSection'] ?? '',
      feeStatus: json['FeeStatus'] ?? '',
      feeStartDate: json['FeeStartDate'] ?? '',
      feeEndDate: json['FeeEndDate'] ?? '',
      resultMap: parseNestedMap(json['ResultMap']),
      attendance: parseNestedMap(json['attendance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Gender': gender,
      'BForm_challanId': bFormChallanId,
      'FatherName': fatherName,
      'FatherPhoneNo': fatherPhoneNo,
      'FatherCNIC': fatherCNIC,
      'StudentRollNo': studentRollNo,
      'StudentID': studentID,
      'ClassSection': classSection,
      'FeeStatus': feeStatus,
      'FeeStartDate': feeStartDate,
      'FeeEndDate': feeEndDate,
      'ResultMap': resultMap,
      'attendance': attendance, 
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'Gender': gender,
      'BForm_challanId': bFormChallanId,
      'FatherName': fatherName,
      'FatherPhoneNo': fatherPhoneNo,
      'FatherCNIC': fatherCNIC,
      'StudentRollNo': studentRollNo,
      'StudentID': studentID,
      'ClassSection': classSection,
      'FeeStatus': feeStatus,
      'FeeStartDate': feeStartDate,
      'FeeEndDate': feeEndDate,
      'ResultMap': resultMap,
      'attendance': attendance, 
    };
  }

  @override
  String toString() {
    return 'Student{name: $name, gender: $gender, bForm_challanId: $bFormChallanId, fatherName: $fatherName, fatherPhoneNo: $fatherPhoneNo, fatherCNIC: $fatherCNIC, studentRollNo: $studentRollNo, studentID: $studentID, classSection: $classSection, feeStatus: $feeStatus, feeStartDate: $feeStartDate, feeEndDate: $feeEndDate}';
  }
}
