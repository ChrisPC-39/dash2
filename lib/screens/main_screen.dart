import 'package:dash2/database/collection.dart';
import 'package:dash2/database/enable_collections.dart';
import 'package:dash2/database/item.dart';
import 'package:dash2/database/setup.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:share_plus/share_plus.dart';

import '../globals.dart';
import 'widgets/BottomAppBar.dart';
import 'widgets/FloatingActionButton.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  List<bool> isExpanded = [];
  List<bool> isEditingTitle = [];

  String input = "";
  String editInput = "";
  String editTitleInput = "";
  String collectionItemEditInput = "";

  FocusNode editNode = FocusNode();
  FocusNode focusNode = FocusNode();
  //FocusNode collectionAddItemNode = FocusNode();
  FocusNode editTitleNode = FocusNode();
  PageController pageController = PageController();
  TextEditingController textController = TextEditingController();
  TextEditingController editController = TextEditingController();
  TextEditingController editTitleController = TextEditingController();
  //TextEditingController collectionEditItemController = TextEditingController();

  List<FocusNode> listAddFocusNode = [];
  List<FocusNode> listEditItemNode = [];
  List<TextEditingController> listAddController = [];
  List<TextEditingController> listEditItemController = [];

  @override
  void initState() {
    final setup = Hive.box("setup5").getAt(0) as Setup;
    pageController = PageController(initialPage: setup.page);

    for(int i = 0; i < Hive.box("collections").length; i++) {
      isExpanded.add(false);
      isEditingTitle.add(false);
      listAddFocusNode.add(FocusNode());
      listAddController.add(TextEditingController());
    }

    super.initState();
  }

  void floatingButtonTap(Function func) {
    func();
    // if(editNode.hasFocus) updateItem();
    // else if(listFocusNode.isNotEmpty && listFocusNode[index].hasFocus) addItemInCollection(index, collection);
    // else if(input == "") focusNode.requestFocus();
    // else if(input != "" && pageController.page == 0) addItem(Item(input, false, false));
    // else if(input != "" && pageController.page == 1) addCollection(Collection(input, 0xFF2196f3, [], [], []));

    input = "";
    textController.text = "";
  }

  void addCollection(Collection newCollection) {
    Hive.box("collections").add(Collection("", 0xFFFFFFFF, ["NULL"], [false], [false]));
    final collectionBox = Hive.box("collections");

    for(int i = Hive.box("collections").length - 1; i >= 1 ; i--) {
      final collection = collectionBox.getAt(i - 1) as Collection;
      collectionBox.putAt(i, collection);
    }

    isExpanded.insert(0, false);
    isEditingTitle.add(false);
    listAddFocusNode.insert(0, FocusNode());
    listAddController.insert(0, TextEditingController());

    Hive.box("collections").putAt(0, newCollection);
  }

  void addItemInCollection(int index) {
    final collection = Hive.box("collections").getAt(index) as Collection;

    listEditItemNode.clear();
    listEditItemController.clear();

    List<String> content = [collectionItemEditInput];
    List<bool> isEditing = [false];
    List<bool> isSelected = [false];

    content += collection.content;
    isEditing += collection.isEditing;
    isSelected += collection.isSelected;

    Hive.box("collections").putAt(index, Collection(
      collection.title, collection.color,
      content, isEditing, isSelected
    ));

    for(int i = 0; i < content.length; i++) {
      listEditItemNode.add(FocusNode());
      listEditItemController.add(TextEditingController());
    }

    collectionItemEditInput = "";
    listAddController[index].text = "";
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

  void initCollectionEdit(int index, int i, Collection collection) {
    List<bool> disableEditing = List.filled(collection.isEditing.length, false);

    disableEditing[i] = true;
    Hive.box("collections").putAt(index, Collection(
      collection.title, collection.color,
      collection.content, disableEditing, collection.isSelected
    ));

    listEditItemNode[i].requestFocus();
    listEditItemController[i].text = collection.content[i];
  }

  void updateCollection(int index) {
    final collection = Hive.box("collections").getAt(index) as Collection;
    int i;

    for(i = 0; i < collection.isEditing.length; i++)
      if(collection.isEditing[i])
        break;

    listEditItemNode[i].unfocus();
    List<String> content = collection.content;
    List<bool> isEditing = collection.isEditing;

    content[i] = collectionItemEditInput.isEmpty ? collection.content[i] : collectionItemEditInput;
    isEditing[i] = false;

    Hive.box("collections").putAt(index, Collection(
      collection.title, collection.color,
      content, isEditing, collection.isSelected
    ));

    collectionItemEditInput = "";
    listEditItemController[i].text = "";
  }

  @override
  Widget build(BuildContext context) {
    final setup = Hive.box("setup5").getAt(0) as Setup;
    final enableCollections = Hive.box("enable_collections").getAt(0) as EnableCollections;

    return GestureDetector(
      onTap: () {
        focusNode.unfocus();
        editNode.unfocus();
        listAddFocusNode.forEach((node) => node.unfocus());
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: CustomFloatingActionButton(
          callback: () => floatingButtonTap(() {
            if(pageController.page == 0) {
              if(editNode.hasFocus) updateItem();
              else if(input == "") focusNode.requestFocus();
              else if(input != "") addItem(Item(input, false, false));
            } else {
              for(int i = 0; i < Hive.box("collections").length; i++) {
                if(listAddFocusNode.isNotEmpty && listAddFocusNode[i].hasFocus) {
                  addItemInCollection(i);
                  return;
                }

                // if(listEditItemNode.isNotEmpty && listEditItemNode[i].hasFocus) {
                //   updateCollection(i);
                //   return;
                // }
              }

              if(input == "") focusNode.requestFocus();
              else if(input != "") addCollection(Collection(input, 0xFF2196f3, [], [], []));

            }
          }),
          icon: !editNode.hasFocus ? Icons.add : Icons.check
        ),
        bottomNavigationBar: CustomBottomAppBar(page: setup.page),
        body: SafeArea(
          child: Column(
            children: [
              _buildInput(),

              Visibility(
                visible: !enableCollections.isEnabled,
                child: _buildPageSelect()
              ),

              Visibility(
                visible: !enableCollections.isEnabled,
                child: Container(height: padding)
              ),

              Expanded(
                child: PageView(
                  physics: enableCollections.isEnabled
                      ? BouncingScrollPhysics()
                      : NeverScrollableScrollPhysics(),
                  controller: pageController,
                  onPageChanged: (value) {
                    final setup = Hive.box("setup5").getAt(0) as Setup;
                    Hive.box("setup5").putAt(0, Setup(setup.theme, setup.size, setup.reverse, setup.useEnter, setup.boxSize, value));
                  },
                  children: [
                    _buildListView(),
                    _buildCollectionView()
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }


  Widget _buildPageSelect() {
    final setup = Hive.box("setup5").getAt(0) as Setup;

    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 40,
              decoration: BoxDecoration(
                  color: setup.page == 0 ? setup.theme == "dark" ? Colors.grey[600] : Colors.grey[200] : Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(60))
              ),
              child: Center(child: Text("List", style: TextStyle(fontSize: 20))),
            )
          ),

          Container(width: padding),

          GestureDetector(
            onTap: () => pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 40,
              decoration: BoxDecoration(
                  color: setup.page == 1 ? setup.theme == "dark" ? Colors.grey[600] : Colors.grey[200] : Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(60))
              ),
              child: Center(child: Text("Folders", style: TextStyle(fontSize: 20))),
            ),
          )
        ]
    );
  }

  Widget _buildCollectionView() {
    return ValueListenableBuilder(
      valueListenable: Hive.box("collections").listenable(),
      builder: (context, itemsBox, _) {
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: Hive.box("collections").length + 1,
          itemBuilder: (context, index) {
            if(Hive.box("collections").isEmpty) return Container();

            if(index == Hive.box("collections").length) return Container(height: editNode.hasFocus ? 80 : 50);

            final collection = Hive.box("collections").getAt(index) as Collection;
            return !collection.title.toLowerCase().contains(input.toLowerCase())
              ? Container()
              : _buildCollection(index, collection);
          }
        );
      }
    );
  }

  PopupMenuItem _buildPopupMenuItem(int i, IconData icon, String text) {
    return PopupMenuItem(
      value: i,
      child: Row(
        children: [
          Icon(icon, size: 30),
          SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 20))
        ]
      )
    );
  }

  Widget _buildCollection(int collectionIndex, Collection collection) {
    final setup = Hive.box("setup5").getAt(0) as Setup;
    int length = isExpanded[collectionIndex] ? collection.content.length : 0;

    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      vsync: this,
      curve: Curves.easeIn,
      child: Container(
        margin: EdgeInsets.fromLTRB(padding, 5, padding, 10),
        constraints: BoxConstraints(minHeight: setup.boxSize + 50),
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gradient: LinearGradient(
            colors: [
              Color(collection.color),
              Color(collection.color).withAlpha(200)
            ],
            begin: FractionalOffset(0.5, 0.0),
            end: FractionalOffset(1.0, 1.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          )
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          editTitleNode.requestFocus();
                          isEditingTitle.fillRange(0, isEditingTitle.length, false);
                          isEditingTitle[collectionIndex] = true;
                          editTitleController.text = collection.title;
                        }),
                        child: !isEditingTitle[collectionIndex]
                          ? Text(
                            collection.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: setup.size - 40, fontWeight: FontWeight.bold, color: Colors.white)
                          ) : Row(
                            children: [
                              Expanded(
                                child: TextField (
                                  textInputAction: setup.useEnter ? TextInputAction.done : TextInputAction.newline,
                                  onSubmitted: (value) {
                                    Hive.box("collections").putAt(collectionIndex, Collection(
                                      editTitleInput.isEmpty ? collection.title : editTitleInput, collection.color,
                                      collection.content, collection.isEditing, collection.isEditing
                                    ));

                                    isEditingTitle[collectionIndex] = false;
                                    editTitleInput = "";
                                    editTitleController.text = "";
                                    setState(() {});
                                  },
                                  textCapitalization: TextCapitalization.sentences,
                                  maxLines: null,
                                  style: TextStyle(fontSize: setup.size - 50, color: Colors.white, fontWeight: FontWeight.bold),
                                  focusNode: editTitleNode,
                                  controller: editTitleController,
                                  onChanged: (value) => setState(() => editTitleInput = value),
                                )
                              ),

                              IconButton(
                                onPressed: () => setState(() {
                                  Hive.box("collections").putAt(collectionIndex, Collection(
                                    editTitleInput.isEmpty ? collection.title : editTitleInput, collection.color,
                                    collection.content, collection.isEditing, collection.isEditing
                                  ));

                                  isEditingTitle[collectionIndex] = false;
                                  editTitleInput = "";
                                  editTitleController.text = "";
                                }),
                                icon: Icon(Icons.check, size: 30, color: Colors.white)
                              )
                            ]
                          )
                      )
                    )
                  ),

                  PopupMenuButton(
                    icon: Icon(Icons.more_vert_rounded, color: Colors.white, size: 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                    color: setup.theme == "light" ? Colors.white : Colors.grey[800],
                    itemBuilder: (context) => [
                      _buildPopupMenuItem(0, Icons.color_lens_outlined, "Change color"),
                      _buildPopupMenuItem(2, Icons.share_rounded, "Share this collection"),
                      _buildPopupMenuItem(1, Icons.delete_forever_rounded, "Delete collection")
                    ],
                    onSelected: (value) {
                      switch(value) {
                        case 0:
                          _showColorPicker(collectionIndex, collection);
                          break;
                        case 1:
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Delete this collection?", style: TextStyle(fontSize: 25)),
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
                                      Hive.box("collections").deleteAt(collectionIndex);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Confirm", style: TextStyle(fontSize: 20)),
                                  )
                                ]
                              );
                            }
                          );
                          break;
                        case 2:
                          String message = "Here's what I need from ${collection.title}:\n";
                          String notTaken = "";
                          String taken = "";

                          for(int j = 0; j < collection.content.length; j++) {
                            if(!collection.isSelected[j]) notTaken += "○ ${collection.content[j]}\n";
                            else taken += "✓ ${collection.content[j]}\n";
                          }

                          message += "$notTaken$taken\n";

                          if(notTaken.isEmpty && taken.isEmpty) break;
                          Share.share(message);

                          break;
                        default: break;
                      }
                    }
                  )
                ]
              )
            ),

            Padding(
              padding: EdgeInsets.only(left: padding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("${collection.content.length == 0
                    ? "Empty"
                    : "${collection.content.length == 1
                      ? "1 item" : "${collection.content.length} items"}"
                  }",
                  style: TextStyle(
                    color: Colors.white, fontSize: 18
                  )
                )
              )
            ),

            Visibility(
              visible: isExpanded[collectionIndex],
              child: Container(
                margin: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textInputAction: setup.useEnter ? TextInputAction.done : TextInputAction.newline,
                        onSubmitted: (value) {
                          if(collectionItemEditInput.isNotEmpty) {
                            listAddFocusNode[collectionIndex].unfocus();
                            addItemInCollection(collectionIndex);
                          }
                        },
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        controller: listAddController[collectionIndex],
                        focusNode: listAddFocusNode[collectionIndex],
                        onChanged: (value) => setState(() => collectionItemEditInput = value),
                        decoration: inputDecoration("Add an item", Icons.check_box_outline_blank_rounded),
                      )
                    ),

                    Container(width: 10),

                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.add, color: Colors.white, size: 40),
                      onPressed: () {
                        if(collectionItemEditInput.isNotEmpty) {
                          listAddFocusNode[collectionIndex].unfocus();
                          addItemInCollection(collectionIndex);
                        }
                      }
                    )
                  ]
                )
              )
            ),

            ListView(
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              children: [
                for(int i = 0; i < length; i++)
                  _buildCollectionItem(collectionIndex, i, collection)
              ]
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(padding, 5, padding, 0),
              child: TextButton(
                style: ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.transparent)),
                onPressed: () => setState(() {
                  isExpanded[collectionIndex] = !isExpanded[collectionIndex];
                }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(isExpanded[collectionIndex] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                    Text(isExpanded[collectionIndex] ? "COLLAPSE" : "EXPAND", style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    ))
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildCollectionItem(int collectionIndex, int itemIndex, Collection collection) {
    final setup = Hive.box("setup5").getAt(0) as Setup;

    return Container(
      margin: EdgeInsets.fromLTRB(padding, 5, padding, 10),
      constraints: BoxConstraints(minHeight: setup.boxSize),
      decoration:  BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: collection.isSelected[itemIndex]
          ? setup.theme == "dark" ? Colors.grey[900] : Colors.grey[400]
          : setup.theme == "dark" ? Colors.grey[800] : Colors.grey[200],
      ),
      child: _buildContainerRow(
        Checkbox(
          activeColor: Colors.blue,
          value: collection.isSelected[itemIndex],
          onChanged: (value) => setState(() {
            ///HOW DOES THIS WORK WTF???
            List<bool> newSelection = collection.isSelected;
            newSelection[itemIndex] = !newSelection[itemIndex];
          })
        ),

        Expanded(
          child: GestureDetector(
            onTap: () => initCollectionEdit(collectionIndex, itemIndex, collection),
            child: !collection.isEditing[itemIndex] ? Text(
              collection.content[itemIndex],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: setup.size - 50, decoration: collection.isSelected[itemIndex] ? TextDecoration.lineThrough : TextDecoration.none)
            ) : TextField(
              textInputAction: setup.useEnter ? TextInputAction.done : TextInputAction.newline,
              onSubmitted: (value) { if(collection.isEditing[collectionIndex]) updateItem(); },
              maxLines: null,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(fontSize: setup.size - 50),
              focusNode: listEditItemNode[itemIndex],
              controller: listEditItemController[itemIndex],
              onChanged: (value) => setState(() => collectionItemEditInput = value),
            )
          )
        ),

        GestureDetector(
          onTap: () {
            if(collection.isEditing[itemIndex]) {
              updateCollection(collectionIndex);
            } else {
              //print("here");
              List<String> content = collection.content; content.removeAt(itemIndex);
              List<bool> isEditing = collection.isEditing; isEditing.removeAt(itemIndex);
              List<bool> isSelected = collection.isSelected; isSelected.removeAt(itemIndex);

              // print(content.length);
              // print(collection.content.length);

              // listEditItemNode.removeAt(itemIndex);
              // listEditItemController.removeAt(itemIndex);

              Hive.box("collections").putAt(collectionIndex, Collection(
                collection.title, collection.color,
                content, isEditing, isSelected
              ));
            }
          },
          child: Padding(
            padding: EdgeInsets.only(right: setup.reverse ? 0 : padding, left: setup.reverse ? padding : 0),
            child: Icon(collection.isEditing[itemIndex] ? Icons.check : Icons.delete_outline_rounded, size: setup.size - 50),
          )
        )
      )
    );
  }

  Widget _buildListView() {
    return ValueListenableBuilder(
      valueListenable: Hive.box("items").listenable(),
      builder: (context, itemsBox, _) {
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: Hive.box("items").length + 1,
          itemBuilder: (context, index) {
            if(Hive.box("items").isEmpty) return Container();

            if(index == Hive.box("items").length) return Container(height: editNode.hasFocus ? 80 : 50);

            final item = Hive.box("items").getAt(index) as Item;
            return !item.content.toLowerCase().contains(input.toLowerCase())
              ? Container()
              : _buildItem(index, item);
          }
        );
      }
    );
  }

  Widget _buildItem(int index, Item item) {
    final setup = Hive.box("setup5").getAt(0) as Setup;

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
              textCapitalization: TextCapitalization.sentences,
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
    final setup = Hive.box("setup5").getAt(0) as Setup;

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
    final setup = Hive.box("setup5").getAt(0) as Setup;

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
              textCapitalization: TextCapitalization.sentences,
              textInputAction: setup.useEnter ? TextInputAction.done : TextInputAction.newline,
              onSubmitted: (value) => floatingButtonTap(() {
                if(pageController.page == 0) {
                  addItem(Item(input, false, false));
                } else {
                  addCollection(Collection(input, 0xFF2196f3, [], [], []));
                }
              }),
              focusNode: focusNode,
              controller: textController,
              decoration: inputDecoration(setup.page == 0
                  ? "Search or add an item"
                  : "Search or add a folder",
                Icons.search),
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

  InputDecoration inputDecoration(String hintText, IconData icon) {
    final setup = Hive.box("setup5").getAt(0) as Setup;

    return InputDecoration(
      filled: true,
      fillColor: setup.theme == "light" ? Colors.grey[200] : Colors.grey[800],
      enabledBorder: outlineBorder(),
      focusedBorder: outlineBorder(),

      prefixIcon: Icon(icon, color: Colors.grey),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey)
    );
  }

  OutlineInputBorder outlineBorder() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(20))
    );
  }

  void _showColorPicker(int index, Collection collection) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [ TextButton(
            child: Text("Confirm", style: TextStyle(fontSize: 20)),
            onPressed: () => Navigator.pop(context),
          )],
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: Color(collection.color),
              onColorChanged: (color) => Hive.box("collections").putAt(index, Collection(
                  collection.title,
                  color.value,
                  collection.content,
                  collection.isSelected,
                  collection.isEditing
              ))
            )
          )
        );
      }
    );
  }
}