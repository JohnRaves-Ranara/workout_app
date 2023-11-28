import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workout_app_idk/models/ExerciseListItem.dart';
import 'package:workout_app_idk/providers/workout_provider.dart';
import 'package:workout_app_idk/models/Workout_model.dart';
import 'package:workout_app_idk/screens/add_exercise_page.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_app_idk/screens/play_exercises_page.dart';
import 'package:workout_app_idk/services/workout_service.dart';

class exercises_page extends StatefulWidget {
  const exercises_page({super.key});

  @override
  State<exercises_page> createState() => _exercises_pageState();
}

class _exercises_pageState extends State<exercises_page> {
  late Box<Workout> workoutBoxRef;
  String selectedRestTimeType = 'min';
  List<String> timeTypes = ['min', 'sec'];
  final restDurationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    workoutBoxRef = Hive.box('workouts');
  }

  @override
  void dispose() {
    Hive.box('workouts').close();
    super.dispose();
  }

  TextStyle textStyle(double? fontsize) {
    return TextStyle(fontSize: fontsize ?? 12, color: Colors.black);
  }

  void showAddRestDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actionsPadding: EdgeInsets.all(10),
          contentPadding: EdgeInsets.all(10),
          actions: [
            ElevatedButton(
              child: Text(
                "Cancel",
                style: textStyle(10),
              ),
              onPressed: (() {
                restDurationController.clear();
                Navigator.pop(context);
              }),
            ),
            ElevatedButton(
              child: Text(
                "Confirm",
                style: textStyle(10),
              ),
              onPressed: (() {
                WorkoutProvider workoutProvider =
                    Provider.of<WorkoutProvider>(context, listen: false);
                Workout? selectedWorkout = workoutProvider.selectedWorkout!;
                // addMidExerciseRest(
                //     selectedWorkoutKey: selectedWorkout.key,
                //     restDuration: int.parse(restDurationController.text.trim()),
                //     selectedRestTimeType: selectedRestTimeType,
                //     selectedWorkoutName: selectedWorkout.name);
                restDurationController.clear();
                Navigator.pop(context);
              }),
            ),
          ],
          title: Text(
            "Add Mid-Exercise Rest",
            style: textStyle(14),
          ),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: textStyle(12),
                  controller: restDurationController,
                  decoration: InputDecoration(
                      labelStyle: textStyle(12),
                      labelText: 'Duration',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15))),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              StatefulBuilder(
                builder: (context, setTimeTypeState) {
                  return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: Colors.black.withOpacity(0.3),
                              width: 1.2)),
                      child: DropdownButton(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          style: textStyle(12),
                          items: timeTypes
                              .map((t) => DropdownMenuItem(
                                    child: Text(t),
                                    value: t,
                                  ))
                              .toList(),
                          value: selectedRestTimeType,
                          onChanged: (String? newVal) {
                            setTimeTypeState(() {
                              selectedRestTimeType = newVal!;
                            });
                          }));
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        List<ExerciseListItem> list = workoutBoxRef
            .get(workoutProvider.selectedWorkout!.key)!
            .exerciseList;
        if (list.length != 0) {
          for (int i = 0; i < list.length; i++) {
            print(list[i].exerciseName);
          }
        } else {
          print("NO EXERCISES YET.");
        }
        return SafeArea(
          child: Scaffold(
            floatingActionButton: SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                spacing: 20,
                icon: Icons.add,
                children: <SpeedDialChild>[
                  SpeedDialChild(
                      shape: CircleBorder(),
                      child: Icon(Icons.access_time),
                      label: "Add Rest",
                      backgroundColor: Colors.green[300],
                      onTap: (() {
                        showAddRestDialog();
                      })),
                  SpeedDialChild(
                      shape: CircleBorder(),
                      child: Icon(Icons.fitness_center),
                      label: "Add Exercise",
                      backgroundColor: Colors.blue[400],
                      onTap: (() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => add_exercise_page()));
                      }))
                ]),
            appBar: AppBar(
                actions: [
                  GestureDetector(
                    onTap: (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => play_exercises_page()));
                    }),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Container(
                        child: Icon(
                          Icons.play_arrow,
                          size: 30,
                        ),
                      ),
                    ),
                  )
                ],
                centerTitle: true,
                backgroundColor: Colors.blue,
                title: Text(
                  "EXERCISES",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                )),
            body: Column(
              children: [
                SizedBox(height: 20),
                ValueListenableBuilder(
                  valueListenable: workoutBoxRef.listenable(),
                  builder: (context, box, _) {
                    List<ExerciseListItem>? exerciseList = box
                        .get(workoutProvider.selectedWorkout!.key)!
                        .exerciseList;

                    if (exerciseList != null) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: exerciseList.length,
                          itemBuilder: (context, index) {
                            var currentItem = exerciseList[index];
                            if (currentItem.type == 'Exercise') {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.amber[400],
                                      borderRadius: BorderRadius.circular(15)),
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(currentItem.exerciseName!),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Chip(
                                            label: Text(
                                              "${currentItem.set_count.toString()} sets",
                                              style: textStyle(10),
                                            ),
                                            backgroundColor: Colors.amber[100],
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Chip(
                                            label: Text(
                                              (currentItem.execution_type ==
                                                      'Reps')
                                                  ? '${currentItem.reps} rep/s'
                                                  : '${currentItem.exercise_duration} ${currentItem.exercise_duration_timetype}',
                                              style: textStyle(10),
                                            ),
                                            backgroundColor: Colors.amber[100],
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Chip(
                                            label: Text(
                                              (currentItem.midset_rest_duration_timetype ==
                                                      'min')
                                                  ? '${currentItem.midset_rest_duration} min rest (per set)'
                                                  : '${currentItem.midset_rest_duration} sec rest (per set)',
                                              style: textStyle(10),
                                            ),
                                            backgroundColor: Colors.amber[100],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Container(
                                  height: 50,
                                  decoration:
                                      BoxDecoration(color: Colors.purple[200]),
                                  child: Center(
                                      child: Text(
                                          "${currentItem.midexercise_rest_duration} ${currentItem.midexercise_rest_duration_timetype!}")),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: Text("NO EXERCISES YET."),
                      );
                    }
                  },
                ),
                Center(
                  child: ElevatedButton(
                    child: Text("CHECK"),
                    onPressed: (() {
                      print(workoutProvider.selectedWorkout!.exerciseList ==
                          null);
                      print(workoutProvider
                          .selectedWorkout!.exerciseList!.length);
                    }),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
