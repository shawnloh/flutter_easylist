import 'package:flutter/material.dart';

final ThemeData _androidTheme = ThemeData(
  buttonColor: Colors.deepPurple,
  primarySwatch: Colors.deepOrange,
  accentColor: Colors.deepPurple,
  brightness: Brightness.light,
);

final ThemeData _iOSTheme = ThemeData(
  primarySwatch: Colors.green,
  accentColor: Colors.greenAccent,
  buttonColor: Colors.deepPurple,
  brightness: Brightness.light,
);

ThemeData getAdaptiveThemeData(context) {
  return Theme.of(context).platform == TargetPlatform.android
      ? _androidTheme
      : _iOSTheme;
}
