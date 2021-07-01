import 'package:hive/hive.dart';

part 'setup.g.dart';

@HiveType(typeId: 0)
class Setup {
  @HiveField(0)
  final String theme;

  @HiveField(1)
  final double size;

  Setup(this.theme, this.size);
}