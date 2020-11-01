import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_text/models/User.dart';

class Post {
  String post_uid;
  String content;
  String author_id;
  Timestamp date;
  User author;

  Post({this.post_uid, this.content, this.author_id, this.date});
  Post.withAuthor({this.post_uid, this.content, this.author, this.date});
}