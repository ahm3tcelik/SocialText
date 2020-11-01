import 'package:social_text/helper/app_localizations.dart';
import 'package:flutter/material.dart';

class PostValidationMixin {
  BuildContext validationContext;
  String validatePost(String value) {
    value = value.trim();
    if(value.isEmpty) {
      return AppLocalizations.of(validationContext).translate('cannot_empty');
    }
    else if(value.length > 1000 ) {
      return AppLocalizations.of(validationContext).translate('post_cannot_gt');
    }
    return null;
  }
}