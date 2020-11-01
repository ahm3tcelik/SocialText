import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_text/models/Message.dart';
import 'package:social_text/models/Post.dart';
import 'package:social_text/models/User.dart';
import 'package:social_text/services/auth.dart';

class DatabaseService {
  final CollectionReference userCollRef =
      Firestore.instance.collection('users');
  final CollectionReference postCollRef =
      Firestore.instance.collection('posts');
  final CollectionReference chatCollRef =
      Firestore.instance.collection('chats');
  final AuthService authService = AuthService();

  DocumentSnapshot lastPostDc;
  DocumentSnapshot lastUserDc;

  /* ----- User CRUD ----- */

  Future updateUser(User user) async {
    return await userCollRef.document(user.uid).setData({
      'uid': user.uid,
      'ad': user.ad,
      'soyad': user.soyad,
      'email': user.email,
      'sifre': user.sifre,
      'photo_url': user.photo_url
    });
  }

  Future<User> getSpesificUser(String uid) async {
    DocumentSnapshot dc = await userCollRef.document(uid).get();
    return User(
        uid: dc.documentID,
        ad: dc.data['ad'],
        soyad: dc.data['soyad'],
        sifre: dc.data['sifre'],
        email: dc.data['email'],
        photo_url: dc.data['photo_url']);
  }

  Future<List<User>> users({int limit, bool isFirst}) async {
    // Supporting Lazy Load
    List<User> userList = List();
    QuerySnapshot querySnapshot;
    if (isFirst || lastUserDc == null)
      querySnapshot = await userCollRef
          .orderBy('ad', descending: false)
          .limit(limit)
          .getDocuments();
    else
      querySnapshot = await userCollRef
          .orderBy('ad', descending: false)
          .startAfterDocument(lastUserDc)
          .getDocuments();

    for (var dc in querySnapshot.documents) {
      userList.add(User(
          uid: dc.documentID,
          ad: dc.data['ad'],
          soyad: dc.data['soyad'],
          email: dc.data['email'],
          photo_url: dc.data['photo_url'],
          sifre: '-1'
          //sifre: dc.data['sifre'],
          ));
      lastUserDc = dc;
    }
    return userList;
  }

  Future<List<User>> searchUser(String key) async {
    List<User> userList = List();

    QuerySnapshot querySnapshot =
        await userCollRef.orderBy('ad', descending: false).getDocuments();

    for (var dc in querySnapshot.documents.where((element) =>
        element.data.toString().toLowerCase().contains(key.toLowerCase()))) {
      userList.add(User(
          uid: dc.documentID,
          ad: dc.data['ad'],
          soyad: dc.data['soyad'],
          email: dc.data['email'],
          photo_url: dc.data['photo_url'],
          sifre: '-1'
          //sifre: dc.data['sifre'],
          ));
    }
    return userList;
  }

  /* ----- Post CRUD ----- */

  Future insertPost(Post post) async {
    var map = {
      'content': post.content,
      'author_id': post.author_id,
      'date': post.date
    };
    await postCollRef.add(map);
  }

  Future<List<Post>> posts({int limit, bool isFirst}) async {
    // Supporting Lazy Load
    List<Post> postList = List();
    QuerySnapshot querySnapshot;
    if (isFirst || lastPostDc == null)
      querySnapshot = await postCollRef
          .orderBy('date', descending: true)
          .limit(limit)
          .getDocuments();
    else
      querySnapshot = await postCollRef
          .orderBy('date', descending: true)
          .startAfterDocument(lastPostDc)
          .limit(limit)
          .getDocuments();

    for (var dc in querySnapshot.documents) {
      User author = await getSpesificUser(dc.data['author_id']);
      postList.add(Post.withAuthor(
        post_uid: dc.documentID,
        content: dc.data['content'],
        author: author,
        date: dc.data['date'],
      ));
      lastPostDc = dc;
    }
    return postList;
  }

  Future<List<Post>> getSpesificPost(String author_id) async {
    List<Post> postList = List();
    QuerySnapshot querySnapshot;
    querySnapshot = await postCollRef
        .where('author_id', isEqualTo: author_id)
        .getDocuments();

    for (var dc in querySnapshot.documents) {
      User author = await getSpesificUser(dc.data['author_id']);
      postList.add(Post.withAuthor(
        post_uid: dc.documentID,
        content: dc.data['content'],
        author: author,
        date: dc.data['date'],
      ));
    }
    return postList;
  }

  Future updatePost(Post post) async {
    FirebaseUser firebaseUser = await authService.getCurrentUser();
    if (firebaseUser.uid == post.author.uid) {
      await postCollRef.document(post.post_uid).setData({
        'author_id': post.author.uid,
        'date': post.date,
        'content': post.content
      });
      return 1;
    } else
      return null;
  }

  Future deletePost(Post post) async {
    FirebaseUser firebaseUser = await authService.getCurrentUser();
    if (firebaseUser.uid == post.author.uid) {
      await postCollRef.document(post.post_uid).delete();
      return 1;
    } else
      return null;
  }

  /* ----- Message CRUD ----- */

  List<Message> _messageListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map((e) {
      return Message(
          uid: e.data['uid'],
          senderId: e.data['senderId'],
          content: e.data['content'],
          isImg: e.data['isImg'],
          time: e.data['time']);
    }).toList();
  }

  Stream<List<Message>> messages(String chatId) {
    return chatCollRef
        .document(chatId)
        .collection(chatId)
        .orderBy('time', descending: false)
        .snapshots()
        .map(_messageListFromSnapshot);
  }

  Future insertMessage(Message message, String chatId) async {
    return await chatCollRef.document(chatId).collection(chatId).add({
      'senderId': message.senderId,
      'content': message.content,
      'isImg': message.isImg,
      'time': message.time
    });
  }
}
