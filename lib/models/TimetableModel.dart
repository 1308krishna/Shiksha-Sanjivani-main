class Timetable {
  final String className;
  final String format;
  final Map<String, Map<String, String>> timetable;

  Timetable({
    required this.className,
    required this.format,
    required this.timetable,
  });

  // Convert a Timetable object to a map to save in Firestore
  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'format': format,
      'timetable': timetable,
    };
  }

  // Create a Timetable object from a map retrieved from Firestore
  factory Timetable.fromMap(Map<String, dynamic> map) {
    return Timetable(
      className: map['className'],
      format: map['format'],
      timetable: Map<String, Map<String, String>>.from(map['timetable'] ?? {}),
    );
  }

  // Optionally, you can add a method to convert to JSON if needed
  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'format': format,
      'timetable': timetable,
    };
  }
}
