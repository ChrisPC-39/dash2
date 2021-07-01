import 'package:hive/hive.dart';

part 'setup.g.dart';

@HiveType(typeId: 0)
class Setup {
  @HiveField(0)
  final String theme;

  @HiveField(1)
  final double size;

  @HiveField(2)
  final bool reverse;

  @HiveField(3)
  final bool useEnter;

  @HiveField(4)
  final double boxSize;

  Setup(this.theme, this.size, this.reverse, this.useEnter, this.boxSize);
}