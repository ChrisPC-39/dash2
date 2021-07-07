import 'package:hive/hive.dart';

part 'enable_collections.g.dart';

@HiveType(typeId: 3)
class EnableCollections {
  @HiveField(0)
  final bool isEnabled;

  EnableCollections(this.isEnabled);
}