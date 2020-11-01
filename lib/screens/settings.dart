import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_text/Helper/ImageHelper.dart';
import 'package:social_text/helper/app_localizations.dart';
import 'package:social_text/models/User.dart';
import 'package:social_text/services/auth.dart';
import 'package:social_text/services/database.dart';
import 'package:social_text/services/storage.dart';
import 'package:social_text/shared/FullImagePage.dart';
import 'package:social_text/shared/Loading.dart';
import 'package:social_text/validation/user_validator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class Settings extends StatefulWidget {
  static const route_id = "/settings";

  @override
  State createState() => SettingsState();
}

class SettingsState extends State<Settings> with UserValidationMixin {
  File _image;
  final settingsFormKey = GlobalKey<FormState>();
  DatabaseService databaseService = DatabaseService();
  TextEditingController adCtrl = TextEditingController();
  TextEditingController soyadCtrl = TextEditingController();
  TextEditingController sifreCtrl = TextEditingController();
  User user;
  bool imageRemoved = false;
  bool imagePicked = false;

  Future getData() async {
    FirebaseUser firebaseUser = await AuthService().getCurrentUser();
    user = await databaseService.getSpesificUser(firebaseUser.uid);
    return user;
  }

  void onSubmit() async {
    if (settingsFormKey.currentState.validate()) {
      user.ad = adCtrl.text;
      user.soyad = soyadCtrl.text;
      sifreCtrl.text = "";
      FocusScope.of(context).unfocus();
      uploadImage().then((value) {
        databaseService.updateUser(user).then((value) {
          Toast.show(
              AppLocalizations.of(context).translate('settings_success'), context,
              backgroundColor: ThemeData.dark().dialogBackgroundColor,
              duration: Toast.LENGTH_LONG);
        });
      });
    }
  }

  Future uploadImage() async {
    var result = await StorageService().uploadProfilePhoto(_image, user.uid);
    if (result == null) {
      Toast.show(
          AppLocalizations.of(context).translate('fail_process'), context,
          backgroundColor: ThemeData.dark().dialogBackgroundColor,
          duration: Toast.LENGTH_LONG);
    } else if (result == -1) {
      //yeni bir resim yüklenmedi veya kaldırıldı.
    } else {
      user.photo_url = result.toString();
      setState(() {});
    }
  }

  Future getImageFromDevice() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    imagePicked = true;
    _image = image;
    setState(() {});
  }

  void bottomSheetSelected(int i) {
    Navigator.pop(context);
    if (i == 0) {
      _image = null;
      imageRemoved = true;
      setState(() {});
    } else {
      getImageFromDevice();
    }
  }

  void showModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              onTap: () => bottomSheetSelected(0),
              title:
                  Text(AppLocalizations.of(context).translate('remove_photo')),
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              onTap: () => bottomSheetSelected(1),
              title:
                  Text(AppLocalizations.of(context).translate('select_photo')),
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.image,
                  color: Colors.white,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    adCtrl.dispose();
    sifreCtrl.dispose();
    soyadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('settings')),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Loading();
              } else {
                user = snapshot.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: SingleChildScrollView(
                          child: Form(
                        key: settingsFormKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: <Widget>[
                                  CircleAvatar(
                                    radius: 100,
                                    backgroundColor:
                                        ThemeData.dark().dialogBackgroundColor,
                                    child: ClipOval(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_image != null) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => FullImagePage(
                                                        imageFile: _image,
                                                        title: AppLocalizations
                                                                .of(context)
                                                            .translate('you'),
                                                        subtitle: AppLocalizations
                                                                .of(context)
                                                            .translate(
                                                                'profile_photo'))));
                                          } else if (user.photo_url.isEmpty) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => FullImagePage(
                                                        imageAsset: ImageHelper
                                                            .defaultLogoPath,
                                                        title: AppLocalizations
                                                                .of(context)
                                                            .translate('you'),
                                                        subtitle: AppLocalizations
                                                                .of(context)
                                                            .translate(
                                                                'profile_photo'))));
                                          } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => FullImagePage(
                                                        imageUrl:
                                                            user.photo_url,
                                                        title: AppLocalizations
                                                                .of(context)
                                                            .translate('you'),
                                                        subtitle: AppLocalizations
                                                                .of(context)
                                                            .translate(
                                                                'profile_photo'))));
                                          }
                                        },
                                        child: SizedBox(
                                            width: 180,
                                            height: 180,
                                            child: _image != null
                                                ? Image.file(_image)
                                                : ImageHelper.getImage(
                                                    fit: BoxFit.fill,
                                                    imageAsset: ImageHelper
                                                        .defaultLogoPath,
                                                    imageUrl: imageRemoved
                                                        ? user.photo_url = ""
                                                        : user.photo_url)),
                                      ),
                                    ),
                                  ),
                                  FloatingActionButton(
                                    onPressed: () => showModal(),
                                    backgroundColor: Colors.blue,
                                    child: Icon(
                                      Icons.camera_enhance,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      child: buildAdField()),
                                ),
                                Flexible(
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      child: buildSurnameField()),
                                )
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: buildEmailField()),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: buildPasswordField()),
                          ],
                        ),
                      )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 15),
                          onPressed: onSubmit,
                          color: ThemeData.dark().buttonColor,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('save'),
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              }
            },
          ),
        ));
  }

  Widget buildAdField() {
    return TextFormField(
      controller: adCtrl..text = user.ad,
      decoration: InputDecoration(
        filled: true,
        border: InputBorder.none,
        labelText:
        AppLocalizations.of(context)
            .translate('name'),
      ),
      validator: validateText,
    );
  }

  Widget buildSurnameField() {
    return TextFormField(
      controller: soyadCtrl
        ..text = user.soyad,
      decoration: InputDecoration(
        filled: true,
        border: InputBorder.none,
        labelText:
        AppLocalizations.of(context)
            .translate('surname'),
      ),
      validator: validateText,
    );
  }

  Widget buildEmailField() {
    return TextFormField(
      enabled: false,
      initialValue: user.email,
      decoration: InputDecoration(
        filled: true,
        border: InputBorder.none,
        labelText: AppLocalizations.of(context)
            .translate('email'),
      ),
    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      controller: sifreCtrl,
      decoration: InputDecoration(
          filled: true,
          border: InputBorder.none,
          labelText: AppLocalizations.of(context)
              .translate('current_password'),
          helperText: AppLocalizations.of(context)
              .translate('required_for_save')),
      validator: (value) {
        return value != user.sifre
            ? AppLocalizations.of(context)
            .translate('wrong_password')
            : null;
      },
    );
  }
}
