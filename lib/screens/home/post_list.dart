import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_text/helper/app_localizations.dart';
import 'package:social_text/models/Post.dart';
import 'package:social_text/services/database.dart';
import 'package:social_text/shared/CustomDialogs.dart';
import 'package:social_text/shared/PostTile.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class PostList extends StatefulWidget {
  final List<Post> postList;
  final FirebaseUser user;

  PostList({this.postList, this.user});

  @override
  State createState() => PostListState();
}

class PostListState extends State<PostList> {
  DatabaseService databaseService = DatabaseService();
  ScrollController scrollController = ScrollController();
  final int maxPostFromScreen = 10;

  Future onDeletePost(Post post) async {
    var result = await databaseService.deletePost(post);
    if (result == null) {
      Toast.show(AppLocalizations.of(context).translate('fail_process'), context,
          duration: Toast.LENGTH_LONG,
          backgroundColor: ThemeData.dark().dialogBackgroundColor);
    } else {
      setState(() {
        widget.postList.remove(post);
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

  void getMoreData() async { // Lazy Load
    var newList = await databaseService.posts(limit: maxPostFromScreen, isFirst: false);

    if(newList.length > 0) {
      widget.postList.addAll(newList);
      setState(() {});
    }
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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: false,
      itemCount: widget.postList.length,
      itemBuilder: (context, index) {
        return PostTile(
          context: context,
          isAuthor: widget.user.uid == widget.postList[index].author.uid,
          post: widget.postList[index],
          delete: () => onDeletePost(widget.postList[index]),
          update: () => CustomDialogs().updatePostDialog(
              context: context,
              post: widget.postList[index],
              onSubmitDialog: (newPost) {
                onUpdatePost(newPost);
                return null;
              }),
        );
      },
    );
  }
}
