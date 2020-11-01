import 'dart:io';
import 'package:social_text/Helper/ImageHelper.dart';
import 'package:flutter/material.dart';

class FullImagePage extends StatelessWidget {
  final File imageFile;
  final String imageUrl;
  final String imageAsset;
  final String title;
  final String subtitle;

  FullImagePage(
      {this.imageFile,
      this.imageAsset,
      this.imageUrl,
      this.title,
      this.subtitle});

  @override
  Widget build(BuildContext context) {

    Widget imageView = ImageHelper.getImage(
        fit: BoxFit.fill,
        imageUrl: this.imageUrl,
        imageAsset: this.imageAsset,
        imageFile: this.imageFile);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text.rich(TextSpan(text: "${title}\n", children: [
          TextSpan(text: subtitle, style: TextStyle(fontSize: 13))
        ])),
        backgroundColor: Colors.black,
      ),
      body: Center(child: imageView),
    );
  }
}
