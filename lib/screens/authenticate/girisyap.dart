import 'package:social_text/helper/app_localizations.dart';
import 'package:social_text/services/auth.dart';
import 'package:social_text/shared/Loading.dart';
import 'package:social_text/validation/user_validator.dart';
import 'package:flutter/material.dart';

class GirisYap extends StatefulWidget {
  final Function toggleView;

  GirisYap({this.toggleView});

  @override
  State createState() => GirisYapState();
}

class GirisYapState extends State<GirisYap> with UserValidationMixin {
  AuthService authService = AuthService();
  String msg = "";
  String email = "";
  String pw = "";
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController pwCtrl = TextEditingController();

  void submit() async {
    if (formKey.currentState.validate()) {
      email = emailCtrl.text.trim();
      pw = pwCtrl.text.trim();
      isLoading = true;
      dynamic result = await authService.girisYap(email, pw);

      if (result != -1) {
        setState(() {
          isLoading = false;
          result == null
              ? msg = AppLocalizations.of(validationContext)
                  .translate('unexpected_error')
              : msg = result.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    validationContext = context;
    return Scaffold(
      body: isLoading
          ? Loading()
          : Container(
              margin: EdgeInsets.only(top: 20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(
                        flex: 1,
                      ),
                      Flexible(
                        child: Image.asset(
                          "assets/images/icon.png",
                        ),
                        flex: 3,
                      ),
                      Spacer(flex:1),
                      Text(
                        AppLocalizations.of(context)
                            .translate('app_title')
                            .toUpperCase(),
                        style: TextStyle(fontSize: 25, letterSpacing: 7),
                      ),
                      Spacer(flex:1),
                      buildMailField(),
                      buildPasswordField(),
                      Padding(padding: EdgeInsets.symmetric(vertical: 5), child: Text(
                        msg,
                        style: TextStyle(color: Colors.red),
                      )),
                      Spacer(
                        flex: 1,
                      ),
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
                                .translate('signin')
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
                          AppLocalizations.of(context).translate('signup_text'),
                          style: TextStyle(fontSize: 13, color: Colors.white60),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
      validator: validateText,
      decoration: InputDecoration(
          labelText: AppLocalizations.of(context).translate('password'),
          prefixIcon: Icon(Icons.lock_outline)),
    );
  }
}
