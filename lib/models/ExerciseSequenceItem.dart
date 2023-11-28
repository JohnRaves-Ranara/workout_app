import 'package:hive/hive.dart';
part 'ExerciseSequenceItem.g.dart';

@HiveType(typeId: 2)
class ExerciseSequenceItem{

  //Exercise, Mid-Set Rest, Mid-Exercise Rest
  @HiveField(0)
  late String type;
  
  @HiveField(1)
  int? duration;

  @HiveField(2)
  String? duration_timetype;

  @HiveField(3)
  int? set_number;

  @HiveField(4)
  String? exercise_name;

  @HiveField(5)
  int? reps;

  @HiveField(6)
  String? execution_type;

  @HiveField(7)
  int? sets;

  @HiveField(8)
  bool? isExerciseCompleted;

}

