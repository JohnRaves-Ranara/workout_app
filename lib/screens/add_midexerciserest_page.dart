import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:workout_app_idk/providers/workout_provider.dart';
import 'package:workout_app_idk/models/ExerciseListItem.dart';
import 'package:workout_app_idk/models/Workout_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workout_app_idk/themes/TextStyles.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_app_idk/services/workout_service.dart';

class add_midexerciserest_page extends StatefulWidget {
  add_midexerciserest_page({super.key});

  @override
  State<add_midexerciserest_page> createState() =>
      _add_midexerciserest_pageState();
}

class _add_midexerciserest_pageState extends State<add_midexerciserest_page> {
  Color green = Color(0xff00c298);
  Color lightGray = Color(0xff222222);
  Color lighterGray = Color.fromARGB(255, 58, 58, 58);
  List<ExerciseListItem>? exerciseList;
  List<String> timeTypes = ['min', 'sec'];
  String selectedTimeType = 'min';
  final midExerciseRestDurationController = TextEditingController();
  WorkoutDataRepository workoutDataRepo = WorkoutDataRepository();
  List<ExerciseListItem> toBeRemoved = [];
  GlobalKey formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    exerciseList =
        context.read<WorkoutProvider>().selectedWorkout!.exerciseList;
  }

  void printexerciseList() {
    print("-" * 10);
    for (ExerciseListItem i in exerciseList!) {
      print(i.type);
    }
    print("-" * 10);
  }

  void addMidExerciseRest(WorkoutProvider workoutProvider) {
    printexerciseList();
    for (ExerciseListItem i in exerciseList!) {
      if (i.type == 'AddRestHolder') {
        toBeRemoved.add(i);
      }
      if (i.type == 'Mid-Exercise Rest Holder') {
        i..type = 'Mid-Exercise Rest';
      }
    }

    printexerciseList();

    exerciseList!.removeWhere((item) => toBeRemoved.contains(item));
    List<ExerciseListItem> updatedExerciseList = exerciseList!;
    workoutDataRepo.addMidExerciseRest(
        selectedWorkoutKey: workoutProvider.selectedWorkout!.key,
        selectedWorkoutName: workoutProvider.selectedWorkout!.name,
        newExerciseList: updatedExerciseList);
  }

  void removeHolders() {
    print("RICKY WHEN I CATCH YOU RICKY");
    printexerciseList();
    for (ExerciseListItem i in exerciseList!) {
      if (i.type != 'Exercise') {
        toBeRemoved.add(i);
      }
    }
    exerciseList!.removeWhere((item) => toBeRemoved.contains(item));
    printexerciseList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        int indexCounter = 0;
        while (indexCounter < exerciseList!.length - 1) {
          if (exerciseList![indexCounter + 1].type == 'Exercise') {
            exerciseList!.insert(
                indexCounter + 1, ExerciseListItem()..type = 'AddRestHolder');
          }
          indexCounter += 2;
        }
        return SafeArea(
          child: Scaffold(
            backgroundColor: lightGray,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: lighterGray,
              actions: [
                Ink(
                  width: 65,
                  height: double.infinity,
                  child: InkWell(
                    onTap: (() {
                      addMidExerciseRest(workoutProvider);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }),
                    child: Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 25,
                    ),
                  ),
                )
              ],
              leading: Ink(
                width: 80,
                height: double.infinity,
                child: InkWell(
                  onTap: (() {
                    removeHolders();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }),
                  child: Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 25,
                  ),
                ),
              ),
              title: Text(
                'Add Mid-Exercise Rest',
                style:
                    TextStyles.mont_semibold(color: Colors.white, fontSize: 14),
              ),
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: exerciseList!.length,
                    itemBuilder: (context, index) {
                      ExerciseListItem currentItem = exerciseList![index];
                      if (currentItem.type == 'Exercise') {
                        if (currentItem.execution_type == 'Duration') {
                          return buildExerciseTile(
                              exerciseName: currentItem.exerciseName!,
                              set_count: currentItem.set_count!,
                              mid_set_rest: currentItem.midset_rest_duration!,
                              mid_set_rest_timetype:
                                  currentItem.midset_rest_duration_timetype!,
                              execution_type: currentItem.execution_type!,
                              duration: currentItem.exercise_duration!,
                              duration_timetype:
                                  currentItem.exercise_duration_timetype);
                        } else {
                          return buildExerciseTile(
                              exerciseName: currentItem.exerciseName!,
                              set_count: currentItem.set_count!,
                              mid_set_rest: currentItem.midset_rest_duration!,
                              mid_set_rest_timetype:
                                  currentItem.midset_rest_duration_timetype!,
                              execution_type: currentItem.execution_type!,
                              reps: currentItem.reps);
                        }
                      } else if (currentItem.type == 'AddRestHolder') {
                        return buildAddRestHolderTile(index);
                      } else {
                        return buildAddRestMidExerciseRestTile(
                            index: index,
                            duration: currentItem.midexercise_rest_duration!,
                            duration_timetype: currentItem
                                .midexercise_rest_duration_timetype!);
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showAddRestDialog(int index) {
    final _formKey = GlobalKey<FormState>(); // Define formKey for validation

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: lightGray,
          title: Text(
            'Add Mid-Exercise Rest',
            style: TextStyles.mont_bold(color: Colors.white, fontSize: 14),
          ),
          content: Form(
            key: _formKey,
            child: StatefulBuilder(
              builder: (context, timetTypeState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextFormField(
                        maxLength: 3,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        // validator: (value) {
                        //   if (value!.isEmpty) {
                        //     return "Can't be empty.";
                        //   } else if (!RegExp(r'^(1-9)+\d*$').hasMatch(value)) {
                        //     return "Positive numbers only.";
                        //   } else {
                        //     return null;
                        //   }
                        // },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Can't be empty.";
                          } else if (!RegExp(r'^[1-9]\d*$').hasMatch(value)) {
                            return "Positive numbers only.";
                          } else if (int.parse(value) <= 9 &&
                              selectedTimeType == 'sec') {
                            return "Should atleast be 10 sec.";
                          } else {
                            return null;
                          }
                        },
                        keyboardType: TextInputType.number,
                        controller: midExerciseRestDurationController,
                        cursorColor: green,
                        decoration: InputDecoration(
                            counterText: '',
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: green))),
                        style: TextStyles.mont_regular(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.grey.shade700, width: 1.3)),
                      child: DropdownButton<String>(
                          padding: EdgeInsets.all(10),
                          dropdownColor: lighterGray,
                          underline: SizedBox(),
                          value: selectedTimeType,
                          onChanged: (newValue) {
                            timetTypeState(() {
                              selectedTimeType = newValue!;
                            });
                          },
                          items: timeTypes
                              .map((timeType) => DropdownMenuItem(
                                    child: Text(
                                      timeType,
                                      style: TextStyles.mont_regular(
                                          fontSize: 12, color: Colors.white),
                                    ),
                                    value: timeType,
                                  ))
                              .toList()),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: (() {
                  midExerciseRestDurationController.clear();
                  Navigator.pop(context);
                }),
                child: Text(
                  'Cancel',
                  style: TextStyles.mont_bold(color: green),
                )),
            TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      exerciseList![index] = ExerciseListItem()
                        ..key = Uuid().v4()
                        ..type = 'Mid-Exercise Rest Holder'
                        ..midexercise_rest_duration = int.parse(
                            midExerciseRestDurationController.text.trim())
                        ..midexercise_rest_duration_timetype = selectedTimeType;
                    });
                    midExerciseRestDurationController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Confirm',
                  style: TextStyles.mont_bold(color: green),
                )),
          ],
        );
      },
    );
  }

  Widget buildMidExerciseRestTile(
      {required int duration, required String duration_timetype}) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: 14.5,
          left: MediaQuery.of(context).size.width * 0.06,
          right: MediaQuery.of(context).size.width * 0.06),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.orange,
        ),
        height: 50,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Mid-Exercise Rest',
                style: TextStyles.mont_bold(color: Colors.white, fontSize: 12),
              ),
              Text('${duration} ${duration_timetype}',
                  style:
                      TextStyles.mont_bold(color: Colors.white, fontSize: 12)),
            ],
          )
        ]),
      ),
    );
  }

  Widget buildAddRestMidExerciseRestTile(
      {required int duration,
      required String duration_timetype,
      required int index}) {
    return FocusedMenuHolder(
      onPressed: (() {
        print(exerciseList![index].type);
      }),
      openWithTap: false,
      menuItems: [
        FocusedMenuItem(
            backgroundColor: green,
            title: Text(
              'Edit',
              style:
                  TextStyles.mont_semibold(color: Colors.white, fontSize: 12),
            ),
            onPressed: (() {
              setState(() {
                selectedTimeType = duration_timetype;
                midExerciseRestDurationController.text = duration.toString();
              });
              showAddRestDialog(index);
            }),
            trailingIcon: Icon(
              Icons.edit,
              size: 25,
              color: Colors.white,
            )),
        FocusedMenuItem(
            backgroundColor: Colors.red,
            title: Text(
              'Delete',
              style:
                  TextStyles.mont_semibold(color: Colors.white, fontSize: 12),
            ),
            onPressed: (() {
              setState(() {
                exerciseList![index] = ExerciseListItem()
                  ..type = 'AddRestHolder';
              });
            }),
            trailingIcon: Icon(
              Icons.delete,
              size: 25,
              color: Colors.white,
            )),
      ],
      child: Padding(
        padding: EdgeInsets.only(
            bottom: 14.5,
            left: MediaQuery.of(context).size.width * 0.06,
            right: MediaQuery.of(context).size.width * 0.06),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.orange,
          ),
          height: 50,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Mid-Exercise Rest',
                  style:
                      TextStyles.mont_bold(color: Colors.white, fontSize: 12),
                ),
                Text('${duration} ${duration_timetype}',
                    style: TextStyles.mont_bold(
                        color: Colors.white, fontSize: 12)),
              ],
            )
          ]),
        ),
      ),
    );
  }

  Widget buildAddRestHolderTile(int index) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: 14.5,
          left: MediaQuery.of(context).size.width * 0.06,
          right: MediaQuery.of(context).size.width * 0.06),
      child: DottedBorder(
        color: Colors.orange,
        strokeWidth: 2,
        dashPattern: [8, 6],
        borderType: BorderType.RRect,
        radius: Radius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: (() {
            showAddRestDialog(index);
          }),
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              // color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 50,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'Add Rest Here',
                      style: TextStyles.mont_regular(
                          color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget buildExerciseTile(
      {required String exerciseName,
      required int set_count,
      required int mid_set_rest,
      required String mid_set_rest_timetype,
      required String execution_type,
      int? reps,
      int? duration,
      String? duration_timetype}) {
    return Container(
      // color: Colors.yellow,
      height: MediaQuery.of(context).size.height * 0.17,
      alignment: Alignment.topCenter,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned(
          top: 60,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black,
            ),
            height: 70,
            width: MediaQuery.of(context).size.width * 0.88,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.orange,
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        '${set_count} sets',
                        style: TextStyles.mont_regular(
                            color: Colors.white, fontSize: 12),
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      Text(
                          (execution_type == 'Reps')
                              ? '${reps} reps'
                              : '${duration} ${duration_timetype}',
                          style: TextStyles.mont_regular(
                              color: Colors.white, fontSize: 12)),
                    ],
                  )
                ]),
          ),
        ),
        Container(
          // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: 90,
          width: MediaQuery.of(context).size.width * 0.88,
          decoration: BoxDecoration(
              color: lighterGray, borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.only(left: 20, top: 15),
                // color: Colors.blue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${exerciseName}',
                      style: TextStyles.mont_bold(
                          color: Colors.white, fontSize: 13),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Mid-Set Rest: ${mid_set_rest} ${mid_set_rest_timetype}',
                      style: TextStyles.mont_regular(
                          color: Colors.grey, fontSize: 12),
                    )
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                child: Container(
                  height: 90,
                  width: 10,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                  ),
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
