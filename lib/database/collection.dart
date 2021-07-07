import 'package:hive/hive.dart';

part 'collection.g.dart';

@HiveType(typeId: 2)
class Collection {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final int color;

  @HiveField(2)
  final List<String> content;

  @HiveField(3)
  final List<bool> isSelected;

  @HiveField(4)
  final List<bool> isEditing;

  Collection(this.title, this.color, this.content, this.isEditing, this.isSelected);
}