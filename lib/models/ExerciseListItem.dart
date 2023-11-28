import 'package:hive/hive.dart';
part 'ExerciseListItem.g.dart';

@HiveType(typeId: 1)
class ExerciseListItem{


  //Exercise or Mid-Exercise Rest
  @HiveField(0)
  late String type;

  //if Exercise ang type
  @HiveField(1)
  String? exerciseName;
  @HiveField(2)
  int? set_count;

  //reps or duration
  @HiveField(3)
  String? execution_type;

  //if duration
  @HiveField(4)
  int? exercise_duration;
  @HiveField(5)
  String? exercise_duration_timetype;

  //if reps
  @HiveField(6)
  int? reps;

  @HiveField(7)
  int? midset_rest_duration; 
  @HiveField(8)
  String? midset_rest_duration_timetype;

  //if midexerciserest ang type
  @HiveField(9)
  int? midexercise_rest_duration;
  @HiveField(10)
  String? midexercise_rest_duration_timetype;

  @HiveField(11)
  late String key;
}