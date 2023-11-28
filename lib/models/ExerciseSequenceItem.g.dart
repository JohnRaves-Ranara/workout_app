// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ExerciseSequenceItem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseSequenceItemAdapter extends TypeAdapter<ExerciseSequenceItem> {
  @override
  final int typeId = 2;

  @override
  ExerciseSequenceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSequenceItem()
      ..type = fields[0] as String
      ..duration = fields[1] as int?
      ..duration_timetype = fields[2] as String?
      ..set_number = fields[3] as int?
      ..exercise_name = fields[4] as String?
      ..reps = fields[5] as int?
      ..execution_type = fields[6] as String?
      ..sets = fields[7] as int?
      ..isExerciseCompleted = fields[8] as bool?;
  }

  @override
  void write(BinaryWriter writer, ExerciseSequenceItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.duration_timetype)
      ..writeByte(3)
      ..write(obj.set_number)
      ..writeByte(4)
      ..write(obj.exercise_name)
      ..writeByte(5)
      ..write(obj.reps)
      ..writeByte(6)
      ..write(obj.execution_type)
      ..writeByte(7)
      ..write(obj.sets)
      ..writeByte(8)
      ..write(obj.isExerciseCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSequenceItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
