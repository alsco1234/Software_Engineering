import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHistoryModel{
  ChatHistoryModel({
    required this.dateTime,
    required this.title,
  });
  final int dateTime;
  final String title;
}