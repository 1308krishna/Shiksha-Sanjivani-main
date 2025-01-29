import 'package:classinsight/Services/Database_Service.dart';
import 'package:classinsight/models/SchoolModel.dart';


    
  void fetchClasses() async {
  List<String> fetchedClasses = await Database_Service.fetchAllClassesbyTimetable(School.schoolID.value, false);
  print('Fetched classes: $fetchedClasses'); // Add this to debug


}

