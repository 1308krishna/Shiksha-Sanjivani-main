import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  String? announcementBy;
  Timestamp? announcementDate;
  String? announcementDescription;
  String? studentID;
  bool? adminAnnouncement;

  Announcement({
    this.announcementBy,
    this.announcementDate,
    this.announcementDescription,
    this.studentID,
    this.adminAnnouncement,
  });


  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      announcementBy: json['AnnouncementBy'] ?? '',
      announcementDate: json['AnnouncementDate'] ?? '',
      announcementDescription: json['AnnouncementDescription'] ?? '',
      studentID: json['StudentID'] ?? '',
      adminAnnouncement: json['AdminAnnouncement'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AnnouncementBy': announcementBy,
      'AnnouncementDate': announcementDate,
      'AnnouncementDescription': announcementDescription,
      'StudentID': studentID,
      'AdminAnnouncement': adminAnnouncement,
    };
  }




}