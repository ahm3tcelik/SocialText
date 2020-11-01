import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:social_text/Helper/ImageHelper.dart';
import 'package:social_text/helper/app_localizations.dart';
import 'package:social_text/models/Post.dart';
import 'package:social_text/models/User.dart';
import 'package:social_text/services/auth.dart';
import 'package:social_text/services/database.dart';
import 'package:social_text/shared/CustomDialogs.dart';
import 'package:social_text/shared/FullImagePage.dart';
import 'package:social_text/shared/Loading.dart';
import 'package:social_text/shared/PostTile.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'messenger/messenger_detail.dart';
import 'settings.dart';

class Profile extends StatefulWidget {
  static const String route_id = "/profile";
  final User user;
  final bool isAuthor;

  Profile({@required this.user, @required this.isAuthor});

  @override
  State createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  DatabaseService databaseService = DatabaseService();

  Future onDeletePost(Post post) async {
    var result = await databaseService.deletePost(post);
    if (result == null) {
      Toast.show(
          AppLocalizations.of(context).translate('fail_process'), context,
          duration: Toast.LENGTH_LONG,
          backgroundColor: ThemeData.dark().dialogBackgroundColor);
    } else {
      setState(() {
        FocusScope.of(context).unfocus();
        Toast.show(
            AppLocalizations.of(context).translate('delete_success'), context,
            duration: Toast.LENGTH_LONG,
            backgroundColor: ThemeData.dark().dialogBackgroundColor);
      });
    }
  }

  Future onUpdatePost(Post post) async {
    var result = await databaseService.updatePost(post);
    if (result == null) {
      Toast.show(
          AppLocalizations.of(context).translate('fail_process'), context,
          duration: Toast.LENGTH_LONG,
          backgroundColor: ThemeData.dark().dialogBackgroundColor);
    } else {
      setState(() {
        Toast.show(
            AppLocalizations.of(context).translate('update_success'), context,
            duration: Toast.LENGTH_LONG,
            backgroundColor: ThemeData.dark().dialogBackgroundColor);
      });
    }
  }

  void onMesajGonder() async {
    FirebaseUser currentUser = await AuthService().getCurrentUser();

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessengerDetail(
              targetUser: widget.user, currentUser: currentUser),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ClipOval(
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FullImagePage(
                                imageUrl: widget.user.photo_url,
                                imageAsset: ImageHelper.defaultLogoPath,
                                title: "${widget.user.ad} ${widget.user.soyad}",
                                subtitle: AppLocalizations.of(context)
                                    .translate('profile_photo'))));
                  },
                  child: ImageHelper.getImage(
                      fit: BoxFit.fill,
                      imageUrl: widget.user.photo_url,
                      imageAsset: ImageHelper.defaultLogoPath)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "${widget.user.ad} ${widget.user.soyad}",
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: widget.isAuthor
                ? Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(Settings.route_id);
                      },
                      shape: Border.all(color: Colors.white60),
                      child: Text(AppLocalizations.of(context)
                          .translate('edit_profile')),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: MaterialButton(
                            onPressed: onMesajGonder,
                            shape: Border.all(color: Colors.white60),
                            child: Text(AppLocalizations.of(context)
                                .translate('send_message')),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: MaterialButton(
                            onPressed: () async {
                              String url =
                                  "mailto:${widget.user.email}?subject=News&body=Ahmet%20celik";
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                Toast.show(
                                    AppLocalizations.of(context)
                                        .translate('fail_url'),
                                    context);
                              }
                            },
                            shape: Border.all(color: Colors.white60),
                            child: Text(AppLocalizations.of(context)
                                .translate('send_email')),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Divider(
            color: Colors.white60,
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: FutureBuilder(
                future: databaseService.getSpesificPost(widget.user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Loading();
                  else {
                    List<Post> postList = snapshot.data;
                    return ListView.builder(
                      shrinkWrap: false,
                      itemCount: postList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.import_contacts,
                                  color: Colors.amber),
                            ),
                            title: Text(
                              AppLocalizations.of(context)
                                  .translate('all_posts'),
                              style: TextStyle(fontSize: 21),
                            ),
                            subtitle: Text("${postList.length} " +
                                AppLocalizations.of(context).translate('post')),
                          );
                        } else {
                          Post post = postList[index - 1];
                          return PostTile(
                            context: context,
                            post: post,
                            isAuthor: widget.isAuthor,
                            delete: () => onDeletePost(post),
                            update: () => CustomDialogs().updatePostDialog(
                                context: context,
                                post: post,
                                onSubmitDialog: (newPost) {
                                  onUpdatePost(newPost);
                                  return null;
                                }),
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
