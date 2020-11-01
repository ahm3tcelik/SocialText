import 'package:social_text/models/Post.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class CustomDialogs {

  void updatePostDialog({BuildContext context, Post post, Function onSubmitDialog(Post post)}) {
    TextEditingController updatePostCtrl = TextEditingController();
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("Yazıyı Güncelle"),
        content: TextField(
          controller: updatePostCtrl..text = post.content,
          decoration: InputDecoration(
              hintText: "Bir söz yazın..."
          ),
        ),
        elevation: 5,
        actions: <Widget>[
          MaterialButton(
            onPressed: () {
              if (updatePostCtrl.text
                  .trim()
                  .length > 1000) {
                Toast.show("Sözünüz 1000 karakterden büyük olamaz", context,
                    gravity: Toast.CENTER);
              } else if (updatePostCtrl.text
                  .trim()
                  .isEmpty) {
                Toast.show("Lütfen geçerli bir söz giriniz.", context,
                    gravity: Toast.CENTER);
              } else {
                post.content = updatePostCtrl.text;
                updatePostCtrl.dispose();
                Navigator.pop(context);
                onSubmitDialog.call(post);
              }
            },
            child: Text("Gönder"),
          ),
        ],
      );
    },);
  }
}