import 'package:flutter/material.dart';

import '../../globals.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final Function callback;
  final IconData icon;

  const CustomFloatingActionButton({Key? key, required this.callback, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: FloatingActionButton(
        onPressed: () => callback(),
        child: Icon(icon, size: 30)
      )
    );
  }
}