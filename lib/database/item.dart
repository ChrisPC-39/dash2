import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 1)
class Item {
  @HiveField(0)
  final String content;

  @HiveField(1)
  final bool isSelected;

  @HiveField(2)
  final bool isEditing;

  Item(this.content, this.isEditing, this.isSelected);
}