import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workout_app_idk/providers/workout_provider.dart';
import 'package:workout_app_idk/models/Workout_model.dart';
import 'package:workout_app_idk/models/ExerciseListItem.dart';
import 'package:uuid/uuid.dart';

class WorkoutDataRepository {
  Box<Workout> workoutBoxRef = Hive.box('workouts');
  Uuid uuid = Uuid();

  void addExercise(
      {required String selectedWorkoutKey,
      required String selectedWorkoutName,
      String? selectedExecutionType,
      String? exerciseName,
      int? set_count,
      int? reps,
      String? selectedDurationTimeType,
      int? exerciseDuration,
      int? midSetRestDuration,
      String? selectedRestTimeType}) {
    var selectedWorkoutRef = workoutBoxRef.get(selectedWorkoutKey);
    List<ExerciseListItem>? exerciseList_fromDB =
        selectedWorkoutRef!.exerciseList;
    ExerciseListItem newExerciseListItem;
    if (selectedExecutionType == 'Reps') {
      newExerciseListItem = ExerciseListItem()
        ..execution_type = selectedExecutionType //Reps
        ..reps = reps;
    } else {
      newExerciseListItem = ExerciseListItem()
        ..execution_type = selectedExecutionType //Duration
        ..exercise_duration_timetype = selectedDurationTimeType
        ..exercise_duration = exerciseDuration;
    }
    newExerciseListItem
      ..key = uuid.v4()
      ..type = 'Exercise'
      ..exerciseName = exerciseName
      ..set_count = set_count
      ..midset_rest_duration = midSetRestDuration
      ..midset_rest_duration_timetype = selectedRestTimeType;

    //update exerciseListFromDB with new value
    exerciseList_fromDB.add(newExerciseListItem);

    Workout newWorkout = Workout()
      ..key = selectedWorkoutKey
      ..name = selectedWorkoutName
      ..exerciseList = exerciseList_fromDB;

    print('add exercise sa repo');
    workoutBoxRef.put(selectedWorkoutKey, newWorkout);
  }

  Workout addWorkout(String workoutName) {
    String key = uuid.v4();
    final workout = Workout()
      ..key = key
      ..name = workoutName
      ..exerciseList = [];

    workoutBoxRef.put(key, workout);
    print('LENGTH OF DB: ${workoutBoxRef.values.toList().length}');
    return workout;
  }

  void addMidExerciseRest(
      {required String selectedWorkoutKey,
      required String selectedWorkoutName,
      required List<ExerciseListItem> newExerciseList}) {
    Workout newWorkout = Workout()
      ..key = selectedWorkoutKey
      ..name = selectedWorkoutName
      ..exerciseList = newExerciseList;

    print('add rest sa repo');
    workoutBoxRef.put(selectedWorkoutKey, newWorkout);

  }
}
