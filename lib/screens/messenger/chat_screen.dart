import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_text/helper/app_localizations.dart';
import 'package:social_text/models/Message.dart';
import 'package:social_text/services/database.dart';
import 'package:social_text/services/storage.dart';
import 'package:social_text/shared/MessageTile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String targetUserId;
  final String chatId;

  ChatScreen({this.currentUserId, this.targetUserId, this.chatId});

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  DatabaseService databaseService = DatabaseService();
  StorageService storageService = StorageService();
  TextEditingController sendMsgCtrl = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode textFieldFocus;

  Future getImageFromDevice() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('send_image')),
          elevation: 5,
          content: Image.file(image, fit: BoxFit.fill),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            MaterialButton(
              onPressed: () async {
                Navigator.pop(context);
                var result = await storageService.uploadChatImage(
                    image, widget.chatId, widget.currentUserId);
                if (result == null) {
                  Toast.show(
                      AppLocalizations.of(context).translate('image_fail'),
                      context,
                      duration: Toast.LENGTH_LONG);
                } else {
                  insertMessage(result.toString(), true);
                }
              },
              child: Text(AppLocalizations.of(context).translate('send')),
            )
          ],
        );
      },
    );
  }

  void onSubmitMsg() async {
    if (sendMsgCtrl.text.trim().isEmpty) {
    } else {
      String msg = sendMsgCtrl.text;
      sendMsgCtrl.text = "";
      insertMessage(msg, false);
    }
  }

  void insertMessage(String content, bool isImg) async {
    databaseService.insertMessage(
        Message(
            time: Timestamp.now(),
            isImg: isImg,
            content: content,
            senderId: widget.currentUserId),
        widget.chatId);
  }

  @override
  void dispose() {
    sendMsgCtrl.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = Provider.of<List<Message>>(context);
    Timer(
        Duration(milliseconds: 500),
        () =>
            scrollController.jumpTo(scrollController.position.maxScrollExtent));
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                controller: scrollController,
                reverse: false,
                itemCount: messages == null ? 0 : messages.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    isSelf: messages[index].senderId == widget.currentUserId
                        ? true
                        : false,
                    msg: messages[index].content,
                    timestamp: messages[index].time,
                    isImg: messages[index].isImg,
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            decoration: BoxDecoration(
                color: Colors.black26, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    getImageFromDevice();
                  },
                  icon: Icon(Icons.photo, color: Colors.white70),
                ),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    focusNode: textFieldFocus,
                    keyboardType: TextInputType.text,
                    onSubmitted: (value) {
                      onSubmitMsg();
                    },
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: AppLocalizations.of(context)
                          .translate('msgbox_placeholder'),
                    ),
                    controller: sendMsgCtrl,
                  ),
                ),
                IconButton(
                  onPressed: () => onSubmitMsg(),
                  icon: Icon(Icons.send, color: Colors.yellow),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
