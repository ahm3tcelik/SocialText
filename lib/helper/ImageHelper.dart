import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageHelper {
  static final String defaultLogoPath = "assets/images/default_logo.jpg";
  BoxFit fit;
  File imageFile;
  String imageAsset;
  String imageUrl;

  static Widget getImage({fit, imageAsset, imageFile, imageUrl}) {
    if (imageUrl != null && imageUrl.toString().isNotEmpty)
      return CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    else if (imageFile != null)
      return Image.file(imageFile, fit: BoxFit.contain);
    else if (imageAsset != null)
      return Image.asset(
        imageAsset,
        fit: BoxFit.contain,
      );
  }
}
