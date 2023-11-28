// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ExerciseListItem.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseListItemAdapter extends TypeAdapter<ExerciseListItem> {
  @override
  final int typeId = 1;

  @override
  ExerciseListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseListItem()
      ..type = fields[0] as String
      ..exerciseName = fields[1] as String?
      ..set_count = fields[2] as int?
      ..execution_type = fields[3] as String?
      ..exercise_duration = fields[4] as int?
      ..exercise_duration_timetype = fields[5] as String?
      ..reps = fields[6] as int?
      ..midset_rest_duration = fields[7] as int?
      ..midset_rest_duration_timetype = fields[8] as String?
      ..midexercise_rest_duration = fields[9] as int?
      ..midexercise_rest_duration_timetype = fields[10] as String?
      ..key = fields[11] as String;
  }

  @override
  void write(BinaryWriter writer, ExerciseListItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.set_count)
      ..writeByte(3)
      ..write(obj.execution_type)
      ..writeByte(4)
      ..write(obj.exercise_duration)
      ..writeByte(5)
      ..write(obj.exercise_duration_timetype)
      ..writeByte(6)
      ..write(obj.reps)
      ..writeByte(7)
      ..write(obj.midset_rest_duration)
      ..writeByte(8)
      ..write(obj.midset_rest_duration_timetype)
      ..writeByte(9)
      ..write(obj.midexercise_rest_duration)
      ..writeByte(10)
      ..write(obj.midexercise_rest_duration_timetype)
      ..writeByte(11)
      ..write(obj.key);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
