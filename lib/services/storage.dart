import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // upload photo, return photoURL
  Future uploadProfilePhoto(File file, String uid) async {
    if(file == null) return -1; // foto kaldırınca file null geliyor.
    StorageReference storageReference =
        firebaseStorage.ref().child('profiles/').child(uid);
    try {
      StorageUploadTask storageUploadTask = storageReference.putFile(file);
      StorageTaskSnapshot storageTaskSnapshot =
          await storageUploadTask.onComplete;
      var url = await storageTaskSnapshot.ref.getDownloadURL();
      return url.toString();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // upload chat images, return photoURL
  Future uploadChatImage(File file, String chatId, String senderId) async {
    StorageReference storageReference =
    firebaseStorage.ref().child('chat_images/$chatId').child(senderId + DateTime.now().toIso8601String());
    try {
      StorageUploadTask storageUploadTask = storageReference.putFile(file);
      StorageTaskSnapshot storageTaskSnapshot =
      await storageUploadTask.onComplete;
      var url = await storageTaskSnapshot.ref.getDownloadURL();
      return url.toString();

    } catch (e) {
      return null;
    }
  }
}
