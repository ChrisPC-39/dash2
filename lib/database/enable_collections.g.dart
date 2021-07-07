// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enable_collections.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnableCollectionsAdapter extends TypeAdapter<EnableCollections> {
  @override
  final int typeId = 3;

  @override
  EnableCollections read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnableCollections(
      fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, EnableCollections obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnableCollectionsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
