import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Workout_model.dart';
import 'package:workout_app_idk/services/workout_service.dart';
import 'package:workout_app_idk/models/ExerciseListItem.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutProvider extends ChangeNotifier {
  WorkoutDataRepository workoutDataRepository = WorkoutDataRepository();
  Workout? _selectedWorkout;

  //selectedWorkout getter
  Workout? get selectedWorkout => _selectedWorkout;

  final workoutBoxRef = Hive.box<Workout>('workouts');

  List<Workout> get workoutDB => workoutBoxRef.values.toList();

  bool get isExerciseListEmpty => selectedWorkout!.exerciseList.isEmpty;

  List<ExerciseListItem> get exerciseListDB => List.from(selectedWorkout!.exerciseList);

  bool get isworkoutDBEmpty => workoutBoxRef.isEmpty;

  void clearDB() {
    final keys = workoutBoxRef.keys.toList();
    for (var key in keys) {
      workoutBoxRef.delete(key);
    }
  }

  //change selected workout
  void selectWorkout(Workout workout) {
    _selectedWorkout = workout;
    // print('WORKOUT CHANGED TO ${_selectedWorkout!.name}');
    notifyListeners();
  }

  // //clear selected workout
  // void clearSelectedWorkout() {
  //   _selectedWorkout = null;
  //   notifyListeners();
  // }

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
    workoutDataRepository.addExercise(
        selectedWorkoutKey: selectedWorkoutKey,
        selectedWorkoutName: selectedWorkoutName,
        selectedExecutionType: selectedExecutionType,
        exerciseName: exerciseName,
        set_count: set_count,
        reps: reps,
        selectedDurationTimeType: selectedDurationTimeType,
        exerciseDuration: exerciseDuration,
        midSetRestDuration: midSetRestDuration,
        selectedRestTimeType: selectedRestTimeType);
    print('add exercise sa provider');
  }

  Workout addWorkout(String workoutName) {
    return workoutDataRepository.addWorkout(workoutName);
  }

  void addMidExerciseRest(
      {required String selectedWorkoutKey,
      required String selectedWorkoutName,
      required List<ExerciseListItem> newExerciseList}) {
    workoutDataRepository.addMidExerciseRest(
        selectedWorkoutKey: selectedWorkoutKey,
        selectedWorkoutName: selectedWorkoutName,
        newExerciseList: newExerciseList);
    print('add rest sa provider');
  }
}
