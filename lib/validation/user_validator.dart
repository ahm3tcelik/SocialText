import 'package:social_text/helper/app_localizations.dart';
import 'package:flutter/material.dart';

class UserValidationMixin {
  BuildContext validationContext;

  String validateEmail(String value) {
    value = value.trim();
    if (value.isEmpty)
      return AppLocalizations.of(validationContext).translate('cannot_empty');
    if (!value.contains('@') || value.length < 3)
      return AppLocalizations.of(validationContext).translate('invalid_email');
    return null;
  }

  String validatePassword(String value) {
    value = value.trim();
    if (value.length < 6)
      return AppLocalizations.of(validationContext)
          .translate('password_min_length');
    return null;
  }

  String validateText(String value) {
    value = value.trim();
    if (value.isEmpty)
      return AppLocalizations.of(validationContext).translate('cannot_empty');
    return null;
  }
}
