import 'package:social_text/helper/app_localizations.dart';
import 'package:social_text/models/User.dart';
import 'package:social_text/services/auth.dart';
import 'package:social_text/shared/Loading.dart';
import 'package:social_text/validation/user_validator.dart';
import 'package:flutter/material.dart';

class KayitOl extends StatefulWidget {
  final Function toggleView;

  KayitOl({this.toggleView});

  @override
  State createState() => KayitOlState();
}

class KayitOlState extends State<KayitOl> with UserValidationMixin {
  String msg = "";
  final AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();
  final User newUser = User();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController surNameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController pwCtrl = TextEditingController();
  TextEditingController pwCtrl2 = TextEditingController();
  bool isLoading = false;

  void submit() async {
    if (formKey.currentState.validate()) {
      isLoading = true;
      newUser.ad = nameCtrl.text.trim();
      newUser.soyad = surNameCtrl.text.trim();
      newUser.email = emailCtrl.text.trim();
      newUser.sifre = pwCtrl.text.trim();
      newUser.photo_url = "";

      dynamic result = await authService.kayitOl(newUser);
      newUser.setClear();

      if (result != -1) {
        setState(() {
          isLoading = false;
          result == null
              ? msg = AppLocalizations.of(context).translate('unexpected_error')
              : msg = result.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    surNameCtrl.dispose();
    emailCtrl.dispose();
    pwCtrl.dispose();
    pwCtrl2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    validationContext = context;
    return Scaffold(
      body: isLoading
          ? Loading()
          : Container(
              margin: EdgeInsets.only(top: 20),
              child: Form(
                  key: formKey,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    children: [
                      Image.asset(
                        "assets/images/icon.png", height: 150,
                      ),
                      Padding(padding: EdgeInsets.all(10),),
                      Row(children: <Widget>[
                        Flexible(
                          child: buildNameField(),
                        ),
                        Flexible(
                          child: buildSurnameField(),
                        )
                      ]),
                      buildMailField(),
                      buildPasswordField(),
                      buildPasswordField2(),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            msg,
                            style: TextStyle(color: Colors.red),
                          )),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          color: Colors.green,
                          onPressed: () => submit(),
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('signup')
                                .toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.toggleView(),
                        child: Text(
                          AppLocalizations.of(context).translate('signin_text'),
                          style: TextStyle(fontSize: 13, color: Colors.white60), textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
            ),
    );
  }

  Widget buildNameField() {
    return TextFormField(
      controller: nameCtrl,
      validator: validateText,
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context).translate('name'),
          prefixIcon: Icon(Icons.account_circle)),
    );
  }

  Widget buildSurnameField() {
    return TextFormField(
      controller: surNameCtrl,
      validator: validateText,
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context).translate('surname'),
          prefixIcon: Icon(Icons.account_circle)),
    );
  }

  Widget buildMailField() {
    return TextFormField(
      controller: emailCtrl,
      validator: validateEmail,
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context).translate('email'),
          hintText: AppLocalizations.of(context).translate('hint_email'),
          prefixIcon: Icon(Icons.email)),
    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      controller: pwCtrl,
      obscureText: true,
      validator: validatePassword,
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context).translate('password'),
          hintText:
              AppLocalizations.of(context).translate('password_min_length'),
          prefixIcon: Icon(Icons.lock_outline)),
    );
  }

  Widget buildPasswordField2() {
    return TextFormField(
      controller: pwCtrl2,
      obscureText: true,
      validator: (value) {
        if(value.trim() != pwCtrl.text.trim())
          return AppLocalizations.of(context).translate('pw_dont_match');
        return null;
      },
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context).translate('password') + " " + AppLocalizations.of(context).translate('confirm'),
          prefixIcon: Icon(Icons.lock_outline)),
    );
  }
}
