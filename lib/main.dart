import 'package:dash2/database/collection.dart';
import 'package:dash2/database/enable_collections.dart';
import 'package:dash2/database/item.dart';
import 'package:dash2/database/setup.dart';
import 'package:dash2/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Hive.registerAdapter(CollectionAdapter());
  Hive.registerAdapter(EnableCollectionsAdapter());

  var setupBox = await Hive.openBox("setup5");
  var itemBox = await Hive.openBox("items");
  var collectionBox = await Hive.openBox("collections");
  var enableCollections = await Hive.openBox("enable_collections");

  if(setupBox.length == 0) setupBox.add(Setup("light", default_size, false, false, default_size, 0));
  if(enableCollections.length == 0) enableCollections.add(EnableCollections(false));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ValueListenableBuilder(
      valueListenable: Hive.box("setup5").listenable(),
      builder: (context, setupBox, _) {
        final setup = Hive.box("setup5").getAt(0) as Setup;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: setup.theme == "light" ? ThemeData.light() : ThemeData.dark().copyWith(colorScheme: ThemeData.dark().colorScheme.copyWith(secondary: Colors.blue)),
          home: MainScreen()
        );
      }
    );
  }
}
