// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CashEntryAdapter extends TypeAdapter<CashEntry> {
  @override
  final int typeId = 2;

  @override
  CashEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CashEntry(
      amount: fields[0] as double,
      type: fields[1] as String,
      date: fields[2] as DateTime,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CashEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
