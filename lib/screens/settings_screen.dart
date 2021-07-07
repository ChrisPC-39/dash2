import 'package:dash2/database/enable_collections.dart';
import 'package:dash2/database/setup.dart';
import 'package:dash2/screens/widgets/FloatingActionButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../globals.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PageController pageController = PageController();
  double pageOffset = 0;

  @override
  void initState() {
    pageController = PageController(viewportFraction: 0.7);
    pageController.addListener(() => setState(() =>
      pageOffset = pageController.page!
    ));

    super.initState();
  }

  void pop() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final setup = Hive.box("setup5").getAt(0) as Setup;
    final enableCollections = Hive.box("enable_collections").getAt(0) as EnableCollections;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: CustomFloatingActionButton(callback: () => pop(), icon: Icons.arrow_back_ios_rounded),
      body: SafeArea(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Container(height: padding),
            Align(
              alignment: Alignment(-0.8, 0),
              child: Text("Settings", style: TextStyle(fontSize: 25))
            ),

            _buildSampleItem(setup),
            _buildReverseOrder(setup),
            _buildSendByEnter(setup),
            _buildEnableCollections(enableCollections),
            _buildChangeFont(setup),
            _buildChangeBoxSize(setup),
            _buildChangeTheme(setup),
            Divider(thickness: 1),
          ]
        )
      )
    );
  }

  Widget _buildSampleItem(Setup setup) {
    return Column(
      children: [
        Container(height: padding),

        Container(
          margin: EdgeInsets.fromLTRB(padding, 5, padding, 10),
          constraints: BoxConstraints(minHeight: setup.boxSize),
          decoration:  BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: setup.theme == "dark" ? Colors.grey[800] : Colors.grey[200],
          ),
          child: _buildContainerRow(
            Checkbox(value: false, onChanged: (value) {}),

            Text("Sample item", textAlign: TextAlign.center, style: TextStyle(fontSize: setup.size - 50)),

            Padding(
              padding: EdgeInsets.only(right: setup.reverse ? 0 : padding, left: setup.reverse ? padding : 0),
              child: Icon(Icons.delete_outline_rounded, size: 30),
            ),

            setup
          )
        )
      ]
    );
  }

  Widget _buildReverseOrder(Setup setup) {
    return SwitchListTile(
      activeColor: Colors.blue,
      title: Text("Reverse button order", style: TextStyle(fontSize: 20)),
      onChanged: (value) { Hive.box("setup5").putAt(0, Setup(setup.theme, setup.size, value, setup.useEnter, setup.boxSize, setup.page)); setState(() {}); },
      value: setup.reverse,
    );
  }

  Widget _buildSendByEnter(Setup setup) {
    return SwitchListTile(
      activeColor: Colors.blue,
      title: Text("Confirm by Enter", style: TextStyle(fontSize: 20)),
      value: setup.useEnter,
      onChanged: (value) { Hive.box("setup5").putAt(0, Setup(setup.theme, setup.size, setup.reverse, value, setup.boxSize, setup.page)); setState(() {}); },
    );
  }

  Widget _buildEnableCollections(EnableCollections enableCollections) {
    return SwitchListTile(
      activeColor: Colors.blue,
      title: Text("Swipe to access Folders", style: TextStyle(fontSize: 20)),
      value: enableCollections.isEnabled,
      onChanged: (value) { Hive.box("enable_collections").putAt(0, EnableCollections(value)); setState(() {}); },
    );
  }

  Widget _buildChangeFont(Setup setup) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment(-1.0, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Text("Change font size", style: TextStyle(fontSize: 20)),
              )
            ),

            MaterialButton(
              child: Column(
                children: [
                  Icon(Icons.settings_backup_restore_rounded),
                  Text("Default")
                ]
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
              onPressed: () { Hive.box("setup5").putAt(0, Setup(setup.theme, default_size, setup.reverse, setup.useEnter, setup.boxSize, setup.page)); setState(() {}); },
            )
          ]
        ),

        Slider(
          max: 40,
          min: 15,
          onChanged: (value) { Hive.box("setup5").putAt(0, Setup(setup.theme, value + 50, setup.reverse, setup.useEnter, setup.boxSize, setup.page)); setState(() {}); },
          value: setup.size - 50,
          label: "${setup.size - 50}",
          divisions: 25,
        )
      ]
    );
  }

  Widget _buildChangeBoxSize(Setup setup) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment(-1.0, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Text("Change box size", style: TextStyle(fontSize: 20)),
              )
            ),

            MaterialButton(
              child: Column(
                children: [
                  Icon(Icons.settings_backup_restore_rounded),
                  Text("Default")
                ]
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
              onPressed: () { Hive.box("setup5").putAt(0, Setup(setup.theme, setup.size, setup.reverse, setup.useEnter, default_size, setup.page)); setState(() {}); },
            )
          ]
        ),

        Slider(
          max: 100,
          min: 50,
          onChanged: (value) { Hive.box("setup5").putAt(0, Setup(setup.theme, setup.size, setup.reverse, setup.useEnter, value, setup.page)); setState(() {}); },
          value: setup.boxSize,
          label: "${setup.boxSize}",
          divisions: 50,
        )
      ]
    );
  }

  Widget _buildChangeTheme(Setup setup) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Align(alignment: Alignment.centerLeft, child: Text("Change theme", style: TextStyle(fontSize: 20))),
        ),

        Container(
          height: 400,
          child: PageView.builder(
            physics: BouncingScrollPhysics(),
            controller: pageController,
            itemCount: 2,
            itemBuilder: (context, index) {
              return _buildParallax(index, setup);
            }
          )
        )
      ]
    );
  }

  Widget _buildParallax(int index, Setup setup) {
    return GestureDetector(
      onTap: () { Hive.box("setup5").putAt(0, Setup(index == 0 ? "light" : "dark", setup.size, setup.reverse, setup.useEnter, setup.boxSize, setup.page)); setState(() {}); },
      child: Transform.scale(
        scale: 1,
        child: Container(
          padding: EdgeInsets.only(right: 20),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  "assets/$index.jpg",
                  height: 370,
                  fit: BoxFit.cover,
                  alignment: Alignment(-pageOffset.abs() + index, 0),
                )
              ),

              Align(
                alignment: Alignment(-0.6, 0.6),
                child: Text(index == 0 ? "Light" : "Dark", style: TextStyle(
                  fontSize: 40, color: Colors.white)
                )
              )
            ]
          )
        )
      ),
    );
  }

  Widget _buildContainerRow(Widget left, Widget center, Widget right, Setup setup) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        setup.reverse ? right : left,
        center,
        setup.reverse ? left : right,
      ]
    );
  }
}