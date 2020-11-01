import 'package:flutter/material.dart';
import 'girisyap.dart';
import 'kayitol.dart';

class Authenticate extends StatefulWidget {

  @override
  State createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate> {
  bool kayitOlAktif = false;

  void toggleView() {
    setState(() {
      kayitOlAktif = !kayitOlAktif;
    });
  }

  @override
  Widget build(BuildContext context) {
    return kayitOlAktif
        ? KayitOl(toggleView: toggleView)
        : GirisYap(toggleView: toggleView);
  }
}
