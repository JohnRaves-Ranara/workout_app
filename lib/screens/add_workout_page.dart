import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:workout_app_idk/models/Workout_model.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_app_idk/services/workout_service.dart';
import 'package:provider/provider.dart';
import 'package:workout_app_idk/providers/workout_provider.dart';

class add_workout_page extends StatefulWidget {
  @override
  State<add_workout_page> createState() => _add_workout_pageState();
}

class _add_workout_pageState extends State<add_workout_page> {
  late Box<Workout> workoutBoxRef;
  Uuid uuid = Uuid();
  @override
  void initState() {
    super.initState();
    workoutBoxRef = Hive.box<Workout>('workouts');
  }

  final workoutNameController = TextEditingController();
  WorkoutDataRepository workoutDataRepo = WorkoutDataRepository();

  @override
  void dispose() {
    Hive.box('workouts').close();
    workoutNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                TextField(
                  controller: workoutNameController,
                ),
                ElevatedButton(
                    onPressed: (() {
                      workoutDataRepo
                          .addWorkout(workoutNameController.text.trim());
                      Navigator.pop(context);
                    }),
                    child: Text("confirm")),
              ],
            ),
          ),
        );
      },
    );
  }
}
