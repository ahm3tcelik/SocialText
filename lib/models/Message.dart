import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String uid;
  String senderId;
  String content;
  Timestamp time;
  bool isImg;

  Message({this.uid, this.senderId, this.content, this.time, this.isImg});
}