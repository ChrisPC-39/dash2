import 'package:dash2/database/collection.dart';
import 'package:dash2/database/item.dart';
import 'package:dash2/database/setup.dart';
import 'package:dash2/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';

import '../../globals.dart';

class CustomBottomAppBar extends StatelessWidget {
  final int page;

  const CustomBottomAppBar({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        height: 70,
        margin: EdgeInsets.only(left: padding, right: padding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.all(padding - 5),
              child: Row(
                children: [
                  _buildIcon(Icons.settings, "Settings", () => Navigator.push(context, PageTransition(type: PageTransitionType.scale, alignment: Alignment.bottomLeft, child: SettingsScreen()))),

                  Container(width: 20),

                  _buildIcon(Icons.delete_forever_rounded, "Delete all", () {
                    final setup = Hive.box("setup5").getAt(0) as Setup;

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Delete all ${setup.page == 0 ? "items in the list" : "collections"}?", style: TextStyle(fontSize: 25)),
                          content: Text("This action can't be undone!", style: TextStyle(fontSize: 20)),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel", style: TextStyle(fontSize: 20)),
                            ),

                            TextButton(
                              onPressed: () {
                                if(setup.page == 0) Hive.box("items").clear();
                                else Hive.box("collections").clear();
                                Navigator.pop(context);
                              },
                              child: Text("Confirm", style: TextStyle(fontSize: 20)),
                            )
                          ]
                        );
                      }
                    );
                  })
                ]
              )
            ),

            Padding(
              padding: EdgeInsets.all(padding - 5),
              child: Row(
                children: [
                  _buildIcon(Icons.check_box, "Clear selection", () {
                    if(page == 1) {
                      for(int i = Hive.box("collections").length - 1; i >= 0; i--) {
                        final collection = Hive.box("collections").getAt(i) as Collection;

                        for(int j = collection.content.length - 1;  j >= 0; j--) {
                          if(collection.isSelected[j]) {
                            final content = collection.content;
                            final isEditing = collection.isEditing;
                            final isSelected = collection.isSelected;

                            content.removeAt(j);
                            isEditing.removeAt(j);
                            isSelected.removeAt(j);

                            Hive.box("collections").putAt(i, Collection(
                              collection.title, collection.color,
                              content, isEditing, isSelected
                            ));
                          }
                        }
                      }
                    } else {
                      for(int i = Hive.box("items").length - 1; i >= 0; i--) {
                        final item = Hive.box("items").getAt(i) as Item;

                        if(item.isSelected) Hive.box("items").deleteAt(i);
                      }
                    }
                  }),

                  Container(width: 20),

                  _buildIcon(Icons.share, "Share", () {
                    if(page == 1) {
                      String message = "Here's my shopping list:\n";
                      String notTaken = "";
                      String taken = "";

                      for(int i = 0; i < Hive.box("collections").length; i++) {
                        final collection = Hive.box("collections").getAt(i) as Collection;

                        message += "From ${collection.title}:\n";

                        for(int j = 0; j < collection.content.length; j++) {
                          if(!collection.isSelected[j]) notTaken += "○ ${collection.content[j]}\n";
                          else taken += "✓ ${collection.content[j]}\n";
                        }

                        message += "$notTaken$taken\n";
                      }

                      if(notTaken.isEmpty && taken.isEmpty) return;
                      Share.share(message);

                      return;
                    }

                    String notTaken = "";
                    String taken = "";

                    for(int i = 0; i < Hive.box("items").length; i++) {
                      final item = Hive.box("items").getAt(i) as Item;

                      if(!item.isSelected) notTaken += "○ ${item.content}\n";
                      else taken += "✓ ${item.content}\n";
                    }

                    if(notTaken.isEmpty && taken.isEmpty) return;
                    Share.share(
                      '''Here's my shopping list:\n$notTaken\n$taken'''
                    );
                  })
                ]
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildIcon(IconData icon, String text, onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(height: 5),
          Icon(icon, size: 25),
          Text(text)
        ]
      )
    );
  }
}