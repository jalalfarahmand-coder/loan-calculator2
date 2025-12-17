// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanModelAdapter extends TypeAdapter<LoanModel> {
  @override
  final int typeId = 0;

  @override
  LoanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanModel(
      principal: fields[0] as double,
      monthlyRate: fields[1] as double,
      months: fields[2] as int,
      graceDays: fields[3] as int,
      installments: (fields[4] as List).cast<double>(),
      createdAt: fields[5] as DateTime,
      installmentType: fields[6] as String,
      title: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LoanModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.principal)
      ..writeByte(1)
      ..write(obj.monthlyRate)
      ..writeByte(2)
      ..write(obj.months)
      ..writeByte(3)
      ..write(obj.graceDays)
      ..writeByte(4)
      ..write(obj.installments)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.installmentType)
      ..writeByte(7)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
