import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes/main.dart';

class ChangeThemeNotifier extends StateNotifier<ThemeData> {
  ChangeThemeNotifier() : super(themeDark);
  void change() {
    state == themeDark ? state = themeLight : state = themeDark;
    print('the theme change **************************');
  }
}

final themeProvider = StateNotifierProvider<ChangeThemeNotifier, ThemeData>(
  (ref) => ChangeThemeNotifier(),
);
