import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_text/services/auth.dart';
import 'package:flutter/material.dart';
import 'screens/home/home.dart';
import 'screens/authenticate/authenticate.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
        stream: AuthService().user,
        builder: (context, snapshot) {
          if(snapshot.connectionState != ConnectionState.active)
            return Scaffold(body: Center(child: CircularProgressIndicator(),),);
          return snapshot.data == null ? Authenticate() : Home();
        },);
  }
}