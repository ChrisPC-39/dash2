import 'package:dash2/database/item.dart';
import 'package:dash2/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';

import '../../globals.dart';

class CustomBottomAppBar extends StatelessWidget {
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

                  _buildIcon(Icons.delete_forever_rounded, "Delete all", () { Hive.box("items").clear(); })
                ]
              )
            ),

            Padding(
              padding: EdgeInsets.all(padding - 5),
              child: Row(
                children: [
                  _buildIcon(Icons.check_box, "Clear selection", () {
                    for(int i = Hive.box("items").length - 1; i > 0; i--) {
                      final item = Hive.box("items").getAt(i) as Item;

                      if(item.isSelected) Hive.box("items").deleteAt(i);
                    }
                  }),

                  Container(width: 20),

                  _buildIcon(Icons.share, "Share", () {
                    String notTaken = "";
                    String taken = "";

                    for(int i = 0; i < Hive.box("items").length; i++) {
                      final item = Hive.box("items").getAt(i) as Item;

                      if(!item.isSelected) notTaken += "○ ${item.content}\n";
                      else taken += "✓ ${item.content}\n";
                    }

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