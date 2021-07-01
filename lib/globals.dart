import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import 'database/setup.dart';

final double padding = 15;
final double default_size = 80;

void switchTheme() {
  final setup = Hive.box("setup4").getAt(0) as Setup;

  Hive.box("setup4").putAt(0, Setup(setup.theme == "light" ? "dark" : "light", setup.size, setup.reverse, setup.useEnter, setup.boxSize));

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarIconBrightness: setup.theme == "light" ? Brightness.light : Brightness.dark,
    statusBarColor: setup.theme == "light" ? ThemeData.dark().bottomAppBarColor : Colors.white,
    systemNavigationBarIconBrightness: setup.theme == "light" ? Brightness.light : Brightness.dark,
    systemNavigationBarColor: setup.theme == "light" ? ThemeData.dark().bottomAppBarColor : Colors.white,
    systemNavigationBarDividerColor: setup.theme == "light" ? ThemeData.dark().bottomAppBarColor : Colors.white,
  ));
}