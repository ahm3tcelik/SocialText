import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_text/models/User.dart';
import 'package:social_text/services/database.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future getCurrentUser() async {
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    return firebaseUser;
  }

  // Oturum değiştiğinde -- Auth change listen
  Stream<FirebaseUser> get user {
    return firebaseAuth.onAuthStateChanged;
  }

  // Giriş Yap
  Future girisYap(String e, String p) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: e, password: p);
      return -1; // success
    }
    on PlatformException catch (exception) {
      return exception.message;
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Kayıt Ol
  Future kayitOl(User user) async {
    try {
      AuthResult result = await firebaseAuth.createUserWithEmailAndPassword(
          email: user.email, password: user.sifre);
      FirebaseUser firebaseUser = result.user;
      await DatabaseService().updateUser(
          User(uid: firebaseUser.uid, ad: user.ad, email: user.email, sifre: user.sifre, soyad: user.soyad, photo_url: user.photo_url));
      return -1; // success
    }
    on PlatformException catch (exception) {
      return exception.message;
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Çıkış Yap
  Future cikisYap() async {
    try {
      return await firebaseAuth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
