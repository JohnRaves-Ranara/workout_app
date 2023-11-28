import 'package:hive/hive.dart';
import 'ExerciseListItem.dart';
part 'Workout_model.g.dart';

@HiveType(typeId: 0)
class Workout{

  @HiveField(0)
  late String key;

  @HiveField(1)
  late String name;
  
  @HiveField(2)
  List<ExerciseListItem> exerciseList = [];
}