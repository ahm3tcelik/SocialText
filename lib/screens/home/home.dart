import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_text/helper/app_localizations.dart';
import 'package:social_text/models/Post.dart';
import 'package:social_text/services/auth.dart';
import 'package:social_text/services/database.dart';
import 'package:social_text/shared/CustomDialogs.dart';
import 'package:social_text/shared/Loading.dart';
import 'package:social_text/shared/PostTile.dart';
import 'package:social_text/validation/post_validator.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../messenger/messenger.dart';
import '../profile.dart';
import 'post_list.dart';

class Home extends StatefulWidget {
  static const String route_id = "/home";

  @override
  State createState() => HomeState();
}

class HomeState extends State<Home> with PostValidationMixin {
  final formKey = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();
  final TextEditingController postCtrl = TextEditingController();
  final DatabaseService databaseService = DatabaseService();
  List<Post> postList = List();
  FirebaseUser user;
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  final int maxPostFromScreen = 10;

  Future getPosts() async {
    user ??= await AuthService().getCurrentUser();
    return databaseService.posts(limit: 5, isFirst: true);
  }

  Future onDeletePost(Post post) async {
    var result = await databaseService.deletePost(post);
    if (result == null) {
      Toast.show(AppLocalizations.of(context).translate('fail_process'), context,
          duration: Toast.LENGTH_LONG,
          backgroundColor: ThemeData.dark().dialogBackgroundColor);
    } else {
      setState(() {
        postList.remove(post);
        FocusScope.of(context).unfocus();
        Toast.show(AppLocalizations.of(context).translate('delete_success'), context,
            duration: Toast.LENGTH_LONG,
            backgroundColor: ThemeData.dark().dialogBackgroundColor);
      });
    }
  }

  Future onUpdatePost(Post post) async {
    var result = await databaseService.updatePost(post);
    if (result == null) {
      Toast.show(AppLocalizations.of(context).translate('fail_process'), context,
          duration: Toast.LENGTH_LONG,
          backgroundColor: ThemeData.dark().dialogBackgroundColor);
    } else {
      setState(() {
        Toast.show(AppLocalizations.of(context).translate('update_success'), context,
            duration: Toast.LENGTH_LONG,
            backgroundColor: ThemeData.dark().dialogBackgroundColor);
      });
    }
  }

  void onNavbarChaned(int index) async {
    if (index == 0)
      scrollController.position.animateTo(0,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
    else if (index == 1)
      Navigator.of(context).pushNamed(Messenger.route_id);
    else if (index == 2) {
      user ??= await AuthService().getCurrentUser();
      databaseService.getSpesificUser(user.uid).then((spesUser) {
        Navigator.of(context).pushNamed(Profile.route_id,
            arguments: Profile(isAuthor: true, user: spesUser));
      });
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    postCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        getMoreData();
      }
    });
    super.initState();
  }

  void getMoreData() async {
    var newList =
        await databaseService.posts(limit: maxPostFromScreen, isFirst: false);
    setState(() {
      postList.addAll(newList);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('app_title')),
        actions: [
          IconButton(
            onPressed: () => authService.cikisYap(),
            icon: Icon(
              Icons.power_settings_new,
              color: Colors.red,
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        key: refreshKey,
        backgroundColor: ThemeData.dark().primaryColor,
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Column(
              children: <Widget>[
                buildShareWidget(),
                DividerTheme(
                  data: ThemeData.dark().dividerTheme,
                  child: Divider(
                    height: 30,
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: getPosts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Loading();
                      } else {
                        postList = snapshot.data;
                        return PostList(user: user, postList: postList);
                        //return buildPostList();
                      }
                    },
                  ),
                )
              ],
            )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onNavbarChaned,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.import_contacts), title: Text(AppLocalizations.of(context).translate('home'))),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text(AppLocalizations.of(context).translate('messaging')),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), title: Text(AppLocalizations.of(context).translate('profile'))),
        ],
      ),
    );
  }

  Widget buildShareWidget() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Form(
                key: formKey,
                child: TextFormField(
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  validator: validatePost,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context).translate('share_placeholder'),
                  ),
                  controller: postCtrl,
                ),
              ),
            ),
            RaisedButton(
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  String content = postCtrl.text;
                  postCtrl.clear();
                  user ??= await AuthService().getCurrentUser();
                  Post post = Post(
                      content: content,
                      author_id: user.uid,
                      date: Timestamp.now());
                  databaseService.insertPost(post).then((value) {
                    Toast.show(AppLocalizations.of(context).translate('post_share_sucess'), context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    setState(() {
                      postList.add(post);
                    });
                  });
                }
                FocusScope.of(context).unfocus();
              },
              child: Text(AppLocalizations.of(context).translate('share')),
            )
          ],
        ),
      ),
    );
  }

  Widget buildPostList() {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: false,
      itemCount: postList.length,
      itemBuilder: (context, index) {
        return PostTile(
          isAuthor: user.uid == postList[index].author.uid,
          post: postList[index],
          delete: () => onDeletePost(postList[index]),
          update: () => CustomDialogs().updatePostDialog(
              context: context,
              post: postList[index],
              onSubmitDialog: (newPost) {
                onUpdatePost(newPost);
                return null;
              }),
        );
      },
    );
  }
}
