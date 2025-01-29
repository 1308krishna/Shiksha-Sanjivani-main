class Class {
  final String className, classId;
  final List<String> subjects, examTypes;
  final Map<String, String> weightage;
  final bool timetable;

  Class({
    required this.className,
    required this.classId,
    required this.timetable,
    required this.subjects,
    required this.examTypes,
    required this.weightage,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      classId: json['classId'],
      timetable: json['timetable'],
      className: json['className'] ?? '',
      subjects: json['subjects'] ?? '',
      examTypes: json['examtypes'] ?? '',
      weightage: json['weightage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'className': className,
      'subjects': subjects,
      'timetable': timetable,
      'examTypes': examTypes,
      'weightage': weightage,
    };
  }
}
