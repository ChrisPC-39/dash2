import 'package:dash2/database/item.dart';
import 'package:dash2/database/setup.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../globals.dart';
import 'widgets/BottomAppBar.dart';
import 'widgets/FloatingActionButton.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String input = "";
  String editInput = "";

  bool hasFocus = false;

  FocusNode editNode = FocusNode();
  FocusNode focusNode = FocusNode();
  TextEditingController textController = TextEditingController();
  TextEditingController editController = TextEditingController();

  void floatingButtonTap() {
    if(hasFocus) updateItem();
    else if(input == "") focusNode.requestFocus();
    else addItem(Item(input, false, false));

    input = "";
    textController.text = "";
  }

  void addItem(Item newItem) {
    Hive.box("items").add(Item("", false, false));
    final itemBox = Hive.box("items");

    for(int i = Hive.box("items").length - 1; i >= 1 ; i--) {
      final item = itemBox.getAt(i - 1) as Item;
      itemBox.putAt(i, item);
    }

    Hive.box("items").putAt(0, newItem);
  }

  void updateItem() {
    int i;

    for(i = 0; i < Hive.box("items").length; i++) {
      final item = Hive.box("items").getAt(i) as Item;

      if(item.isEditing) break;
    }

    final item = Hive.box("items").getAt(i) as Item;

    editNode.unfocus();
    Hive.box("items").putAt(i, Item(editInput.isEmpty ? item.content : editInput, false, item.isSelected));

    setState(() => hasFocus = false);
    editInput = "";
    editController.text = "";
  }

  void initItemEdit(int index, Item item) {
    for(int i = 0; i < Hive.box("items").length; i++) {
      final forItem = Hive.box("items").getAt(i) as Item;

      Hive.box("items").putAt(i, Item(forItem.content, false, forItem.isSelected));
    }

    editNode.requestFocus();
    editController.text = item.content;
    Hive.box("items").putAt(index, Item(item.content, true, item.isSelected));
  }

  void setCallback(bool value) {
    setState(() => hasFocus = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => focusNode.unfocus(),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CustomFloatingActionButton(
          callback: () => floatingButtonTap(),
          icon: !hasFocus ? Icons.add : Icons.check
        ),
        bottomNavigationBar: CustomBottomAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              _buildInput(),
              _buildPageSelect(),
              Container(height: padding),
              PageView(
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildListView(),
                ]
              )
            ]
          )
        )
      )
    );
  }

  Widget _buildPageSelect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.all(Radius.circular(60))
          ),
          child: Center(child: Text("List", style: TextStyle(fontSize: 20))),
        ),

        Container(width: padding),

        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.all(Radius.circular(60))
          ),
          child: Center(child: Text("Collections", style: TextStyle(fontSize: 20))),
        )
      ]
    );
  }

  Widget _buildListView() {
    return ValueListenableBuilder(
      valueListenable: Hive.box("items").listenable(),
      builder: (context, itemsBox, _) {
        return Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: Hive.box("items").length,
            itemBuilder: (context, index) {
              if(Hive.box("items").isEmpty) return Container();

              final item = Hive.box("items").getAt(index) as Item;

              return !item.content.toLowerCase().contains(input)
                ? Container()
                : _buildItem(index, item);
            }
          )
        );
      }
    );
  }

  Widget _buildItem(int index, Item item) {
    final setup = Hive.box("setup4").getAt(0) as Setup;

    return Container(
      margin: EdgeInsets.fromLTRB(padding, 5, padding, 10),
      constraints: BoxConstraints(minHeight: setup.boxSize),
      decoration:  BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: item.isSelected
            ? setup.theme == "dark" ? Colors.grey[900] : Colors.grey[400]
            : setup.theme == "dark" ? Colors.grey[800] : Colors.grey[200],
      ),
      child: _buildContainerRow(
        Checkbox(
          activeColor: Colors.blue,
          value: item.isSelected,
          onChanged: (value) => Hive.box("items").putAt(index, Item(item.content, item.isEditing, value!)),
        ),

        Expanded(
          child: GestureDetector(
            onTap: () => initItemEdit(index, item),
            child: !item.isEditing ? Text(
              item.content,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: setup.size - 50, decoration: item.isSelected ? TextDecoration.lineThrough : TextDecoration.none)
            ) : TextField(
              textInputAction: setup.useEnter ? TextInputAction.done : TextInputAction.newline,
              onSubmitted: (value) { if(item.isEditing) updateItem(); },
              maxLines: null,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: setup.size - 50),
              focusNode: editNode,
              controller: editController,
              onChanged: (value) => setState(() => editInput = value),
            )
          )
        ),

        GestureDetector(
          onTap: () {
            if(item.isEditing) updateItem();
            else Hive.box("items").deleteAt(index);
          },
          child: Padding(
            padding: EdgeInsets.only(right: setup.reverse ? 0 : padding, left: setup.reverse ? padding : 0),
            child: Icon(item.isEditing ? Icons.check : Icons.delete_outline_rounded, size: setup.size - 50),
          )
        )
      )
    );
  }

  Widget _buildContainerRow(Widget left, Widget center, Widget right) {
    final setup = Hive.box("setup4").getAt(0) as Setup;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        setup.reverse ? right : left,
        center,
        setup.reverse ? left : right,
      ]
    );
  }

  Widget _buildInput() {
    final setup = Hive.box("setup4").getAt(0) as Setup;

    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      margin: EdgeInsets.fromLTRB(10, 20, 0, 10),
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            width: focusNode.hasFocus ? MediaQuery.of(context).size.width * 0.70 : MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              textInputAction: setup.useEnter ? TextInputAction.done : TextInputAction.newline,
              onSubmitted: (value) => floatingButtonTap(),
              focusNode: focusNode,
              controller: textController,
              decoration: inputDecoration(),
              onChanged: (String value) => setState(() => input = value),
            )
          ),

          Container(width: 10),

          Visibility(
            visible: focusNode.hasFocus,
            child: Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 5),
                child: GestureDetector(
                  child: Text("Cancel", style: TextStyle(color: Colors.blue, fontSize: 20), maxLines: 1),
                  onTap: () => setState(() {
                    textController.text = "";
                    input = "";
                    focusNode.unfocus();
                  })
                )
              )
            )
          )
        ]
      )
    );
  }

  InputDecoration inputDecoration() {
    final setup = Hive.box("setup4").getAt(0) as Setup;

    return InputDecoration(
      filled: true,
      fillColor: setup.theme == "light" ? Colors.grey[200] : Colors.grey[800],
      enabledBorder: outlineBorder(),
      focusedBorder: outlineBorder(),

      prefixIcon: Icon(Icons.search, color: Colors.grey),
      hintText: "Search or add an item",
      hintStyle: TextStyle(color: Colors.grey)
    );
  }

  OutlineInputBorder outlineBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(20))
    );
  }
}