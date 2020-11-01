import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_text/Helper/ImageHelper.dart';
import 'package:social_text/models/User.dart';
import 'package:social_text/screens/messenger/chat_screen.dart';
import 'package:social_text/services/database.dart';
import 'package:social_text/shared/FullImagePage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessengerDetail extends StatefulWidget {
  static const String route_id = "/messenger_detail";
  final User targetUser;
  final FirebaseUser currentUser;

  MessengerDetail({this.targetUser, this.currentUser});

  @override
  State createState() => MessengerDetailState();
}

class MessengerDetailState extends State<MessengerDetail> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String getChatId() {
    String id = widget.currentUser.uid;
    String targetId = widget.targetUser.uid;
    return (id.hashCode < targetId.hashCode)
        ? "${id}${targetId}"
        : "${targetId}${id}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text("${widget.targetUser.ad} ${widget.targetUser.soyad}"),
            CircleAvatar(
              child: GestureDetector(
                onTap: () {
                  if(widget.targetUser.photo_url.isEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FullImagePage(imageAsset: ImageHelper.defaultLogoPath, title: "${widget.targetUser.ad} ${widget.targetUser.soyad}", subtitle: "")));
                  }
                  else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FullImagePage(imageUrl: widget.targetUser.photo_url, title: "${widget.targetUser.ad} ${widget.targetUser.soyad}", subtitle: "")));
                  }
                },
                child: ClipOval(
                    child: ImageHelper.getImage(fit: BoxFit.fill, imageAsset: ImageHelper.defaultLogoPath, imageUrl: widget.targetUser.photo_url)),
              ),
            ),
          ],
        ),
      ),
      body: StreamProvider.value(
        value: DatabaseService().messages(getChatId()),
        child: ChatScreen(
          currentUserId: widget.currentUser.uid,
          targetUserId: widget.targetUser.uid,
          chatId: getChatId(),
        ),
      ),
    );
  }
}
