// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Workout_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 0;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout()
      ..key = fields[0] as String
      ..name = fields[1] as String
      ..exerciseList = (fields[2] as List).cast<ExerciseListItem>();
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.exerciseList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
