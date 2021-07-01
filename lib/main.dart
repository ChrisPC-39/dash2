import 'package:dash2/database/item.dart';
import 'package:dash2/database/setup.dart';
import 'package:dash2/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'globals.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(SetupAdapter());
  Hive.registerAdapter(ItemAdapter());

  var setupBox = await Hive.openBox("setup4");
  var itemBox = await Hive.openBox("items");

  if(setupBox.length == 0) setupBox.add(Setup("light", default_size, false, false, default_size));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("setup4").listenable(),
      builder: (context, setupBox, _) {
        final setup = Hive.box("setup4").getAt(0) as Setup;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: setup.theme == "light" ? ThemeData.light() : ThemeData.dark().copyWith(colorScheme: ThemeData.dark().colorScheme.copyWith(secondary: Colors.blue)),
          home: MainScreen()
        );
      }
    );
  }
}
