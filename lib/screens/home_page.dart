import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workout_app_idk/models/ExerciseListItem.dart';
import 'package:workout_app_idk/screens/add_exercise_page.dart';
import 'package:workout_app_idk/screens/add_midexerciserest_page.dart';
import 'package:workout_app_idk/models/Workout_model.dart';
import 'package:provider/provider.dart';
import 'package:workout_app_idk/providers/workout_provider.dart';
import 'package:workout_app_idk/screens/play_exercises_page.dart';
import 'package:workout_app_idk/themes/TextStyles.dart';
import 'package:workout_app_idk/services/workout_service.dart';

class home_page extends StatefulWidget {
  const home_page({super.key});

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  late int pageIndex;
  late Box<Workout> workoutBoxRef;
  final workoutNameController = TextEditingController();
  List<String> timeTypes = ['min', 'sec'];
  String selectedTimeType = 'min';
  final midExerciseRestDurationController = TextEditingController();
  List<ExerciseListItem>? addRestExerciseList;
  List<List<dynamic>> modified = [];
  late List<Workout> workouts;
  WorkoutDataRepository workoutDataRepo = WorkoutDataRepository();

  Color green = Color(0xff00c298);
  Color lightGray = Color(0xff222222);
  Color lighterGray = Color.fromARGB(255, 58, 58, 58);
  PageController pc = PageController();

  @override
  void initState() {
    pageIndex = 0;
    WorkoutProvider prov = context.read<WorkoutProvider>();
    workoutBoxRef = Hive.box<Workout>('workouts');
    workouts = prov.workoutDB;
    if (!prov.isworkoutDBEmpty && prov.selectedWorkout==null) {
      prov.selectWorkout(workouts[0]);
    }

    print('keys');
    for (String key in workoutBoxRef.keys) {
      print(key);
    }
  }

  @override
  void dispose() {
    Hive.box('workouts').close();
    super.dispose();
  }

  showWorkoutActionsModalSheets() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(shrinkWrap: true, children: [
            Ink(
                decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15))),
                height: 60,
                child: InkWell(
                  onTap: (() {
                    showAddWorkoutDialog(isUpdate: true);
                  }),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rename routine',
                          style: TextStyles.mont_semibold(color: Colors.white),
                        ),
                        Icon(Icons.edit, size: 20, color: Colors.white)
                      ],
                    ),
                  ),
                )),
            Ink(
                color: lightGray,
                height: 60,
                child: InkWell(
                  onTap: (() {
                    showDeleteWorkoutConfirmation();
                  }),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delete routine',
                          style: TextStyles.mont_semibold(color: Colors.white),
                        ),
                        Icon(Icons.delete, size: 20, color: Colors.white)
                      ],
                    ),
                  ),
                ))
          ]);
        });
  }

  showWorkoutListModalSheet(List<Workout> workouts) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: workouts.length + 1,
            itemBuilder: (context, index) {
              if (index == workouts.length) {
                return Material(
                  color: lightGray,
                  child: Ink(
                    decoration: BoxDecoration(
                        color: green,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(15))),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: InkWell(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      onTap: (() {
                        showAddWorkoutDialog(isUpdate: false);
                      }),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Add Workout Routine',
                            style:
                                TextStyles.mont_semibold(color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Ink(
                  decoration: BoxDecoration(
                      color: lightGray,
                      borderRadius: (index == 0)
                          ? BorderRadius.vertical(top: Radius.circular(15))
                          : null),
                  height: 60,
                  child: InkWell(
                    borderRadius: (index == 0)
                        ? BorderRadius.vertical(top: Radius.circular(15))
                        : null,
                    onTap: (() {
                      setState(() {
                        pc.animateToPage(index,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeIn);
                      });
                      Navigator.pop(context);
                    }),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            workouts[index].name,
                            style:
                                TextStyles.mont_semibold(color: Colors.white),
                          ),
                          (workouts[index].key ==
                                  context
                                      .read<WorkoutProvider>()
                                      .selectedWorkout!
                                      .key)
                              ? Icon(Icons.check, color: Colors.white, size: 20)
                              : SizedBox()
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        });
  }

  showAddExerciseListItemModalSheet() {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        context: context,
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children: [
              Ink(
                decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15))),
                height: 60,
                child: InkWell(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  onTap: (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => add_exercise_page()));
                  }),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Exercise',
                            style: TextStyles.mont_semibold(
                                color: Colors.white, fontSize: 14)),
                        Icon(
                          Icons.fitness_center,
                          size: 20,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Ink(
                color: lightGray,
                height: 60,
                child: InkWell(
                  onTap: (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => add_midexerciserest_page()));
                  }),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Mid-Exercise Rest',
                            style: TextStyles.mont_semibold(
                                color: Colors.white, fontSize: 14)),
                        Icon(
                          Icons.access_alarm,
                          size: 20,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void showAddWorkoutDialog({required bool isUpdate}) {
    WorkoutProvider workProv = context.read<WorkoutProvider>();
    if(isUpdate) workoutNameController.text = workProv.selectedWorkout!.name;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: lightGray,
            title: Text(
              'Add a Workout Routine',
              style: TextStyles.mont_bold(color: Colors.white, fontSize: 14),
            ),
            content: TextField(
              controller: workoutNameController,
              cursorColor: green,
              decoration: InputDecoration(
                  hintText: 'Ex: Leg Day',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: green))),
              style: TextStyles.mont_regular(color: Colors.white, fontSize: 14),
            ),
            actions: [
              TextButton(
                  onPressed: (() {
                    workoutNameController.clear();
                    Navigator.pop(context);
                  }),
                  child: Text(
                    'Cancel',
                    style: TextStyles.mont_bold(color: green),
                  )),
              TextButton(
                  onPressed: (() {
                    if (isUpdate) {
                      workoutDataRepo.updateWorkout(workProv.selectedWorkout!,
                          workoutNameController.text.trim());
                    } else {
                      Workout newlyAddedWorkout = workoutDataRepo
                          .addWorkout(workoutNameController.text.trim());
                      workProv.selectWorkout(newlyAddedWorkout);
                    }
                    workoutNameController.clear();

                    Navigator.popUntil(context, (route) => route.isFirst);
                  }),
                  child: Text(
                    'Confirm',
                    style: TextStyles.mont_bold(color: green),
                  )),
            ],
          );
        });
  }

  Widget topWidgets(WorkoutProvider workoutProvider) {
    workouts = workoutProvider.workoutDB;
    return Padding(
      padding: EdgeInsets.only(
          top: 20,
          left: MediaQuery.of(context).size.width * 0.06,
          right: MediaQuery.of(context).size.width * 0.06),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Ink(
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(15)),
            height: 50,
            width: MediaQuery.of(context).size.width * 0.72,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: (() {
                showWorkoutListModalSheet(workouts);
              }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      workoutProvider.selectedWorkout!.name,
                      style: TextStyles.mont_bold(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 30,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: (() {
              showWorkoutActionsModalSheets();
            }),
            borderRadius: BorderRadius.circular(10),
            child: Ink(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                height: 48,
                width: MediaQuery.of(context).size.width * 0.12,
                child:
                    Center(child: Icon(Icons.more_vert, color: Colors.white))),
          )
        ],
      ),
    );
  }

  Widget listViewContent(WorkoutProvider workoutProvider) {
    List<Workout> workouts1 = workoutProvider.workoutDB;
    return Column(
      children: [
        topWidgets(workoutProvider),
        SizedBox(
          height: 30,
        ),
        Expanded(
          // color: Colors.blue,
          child: PageView.builder(
            controller: pc,
            onPageChanged: (value) {
              print("ONPAGE CHANGED CLICKED");
              workoutProvider.selectWorkout(workoutProvider.workoutDB[value]);
              print(
                  "ONPAGECHANGED, SELECTEDWORKOUT CHANGED TO: ${workoutProvider.selectedWorkout!.name}");
              setState(() {
                pageIndex = value;
              });
            },
            itemCount: workouts1.length,
            itemBuilder: (context, index) {
              if (workoutProvider.isExerciseListEmpty) {
                return Column(
                  children: [
                    Flexible(
                      child: Center(
                        child: GestureDetector(
                          onTap: (() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => add_exercise_page()));
                          }),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: green,
                                  borderRadius: BorderRadius.circular(15)),
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  Text(
                                    'Add your first exercise!',
                                    style: TextStyles.mont_semibold(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    )
                  ],
                );
              } else {
                Workout currentWorkout = workouts1[index];
                return ListView.builder(
                  itemCount: currentWorkout.exerciseList.length,
                  itemBuilder: (context, index) {
                    ExerciseListItem currentItem =
                        currentWorkout.exerciseList[index];
                    if (currentItem.type == 'Exercise') {
                      if (currentItem.execution_type == 'Duration') {
                        return buildExerciseTile(
                            exerciseObject: currentItem,
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
                            exerciseObject: currentItem,
                            exerciseName: currentItem.exerciseName!,
                            set_count: currentItem.set_count!,
                            mid_set_rest: currentItem.midset_rest_duration!,
                            mid_set_rest_timetype:
                                currentItem.midset_rest_duration_timetype!,
                            execution_type: currentItem.execution_type!,
                            reps: currentItem.reps);
                      }
                    } else {
                      return GestureDetector(
                        onTap: (() {
                          print(currentItem.type);
                        }),
                        child: buildMidExerciseRestTile(
                            midExerciseRestObject: currentItem,
                            duration: currentItem.midexercise_rest_duration!,
                            duration_timetype: currentItem
                                .midexercise_rest_duration_timetype!),
                      );
                    }
                  },
                );
              }
            },
          ),
        )
      ],
    );
  }

  Widget buildFloatingActionRow() {
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        alignment: Alignment.center,
        height: 50,
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
          color: green,
          borderRadius: BorderRadius.circular(45),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: (() {
                  showAddExerciseListItemModalSheet();
                }),
                child: Container(
                  height: double.infinity,
                  //I DONT FUCKING KNOW WHY
                  //BUT IF I REMOVE THIS COLOR
                  //THE EXPANDED DOES NOT SOMEHOW WORK
                  //AND EVERYWHERE BUT THE ICON IS A DEADZONE.
                  //WITHOUT THIS YOU AHVE TO FOCUS ON CLICKING THE SMALL FUCKIGN
                  //ICON.
                  color: Colors.transparent,
                  child: Icon(
                    Icons.add_circle_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: (() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => play_exercises_page()));
                }),
                child: Container(
                  color: Colors.transparent,
                  height: double.infinity,
                  child: Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void printExerciseList() {
    print('-' * 10);
    if (!context.read<WorkoutProvider>().isExerciseListEmpty) {
      for (ExerciseListItem i
          in context.read<WorkoutProvider>().exerciseListDB) {
        print(i.type);
      }
    } else {
      print("EMPTY DB, cant print exercise list");
    }
    print('-' * 10);
  }

  @override
  Widget build(BuildContext context) {
    print("WIDGET BUILD INITIAL");

    return ValueListenableBuilder<Box<Workout>>(
        valueListenable: workoutBoxRef.listenable(),
        builder: (context, box, _) {
          WorkoutProvider prov = context.read<WorkoutProvider>();
          print("WIDGET BUILD!");
          return SafeArea(
            child: Scaffold(
              backgroundColor: lightGray,
              floatingActionButton:
                  (!context.read<WorkoutProvider>().isworkoutDBEmpty)
                      ? buildFloatingActionRow()
                      : SizedBox(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              body: Consumer<WorkoutProvider>(
                  builder: (context, workoutProvider, child) {
                if (workoutProvider.isworkoutDBEmpty) {
                  print("empty build");
                  return Center(
                      child: GestureDetector(
                    onTap: (() {
                      showAddWorkoutDialog(isUpdate: false);
                    }),
                    child: Container(
                        decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(15)),
                        padding: EdgeInsets.all(10),
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            Text(
                              'Add your first Workout Routine!',
                              style: TextStyles.mont_semibold(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ],
                        )),
                  ));
                } else {
                  print("not empty build");
                  printExerciseList();
                  return listViewContent(workoutProvider);
                }
              }),
            ),
          );
        });
  }

  Widget buildMidExerciseRestTile(
      {required ExerciseListItem midExerciseRestObject,
      required int duration,
      required String duration_timetype}) {
    WorkoutProvider workProv = context.read<WorkoutProvider>();
    return FocusedMenuHolder(
      onPressed: (() {}),
      menuItems: [
        FocusedMenuItem(
            trailingIcon: Icon(
              Icons.edit,
              size: 25,
              color: Colors.white,
            ),
            backgroundColor: green,
            title: Text(
              'Edit',
              style:
                  TextStyles.mont_semibold(color: Colors.white, fontSize: 12),
            ),
            onPressed: (() {
              showUpdateMidExerciseRest(midExerciseRestObject);
            })),
        FocusedMenuItem(
            trailingIcon: Icon(
              Icons.delete,
              size: 25,
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
            title: Text(
              'Delete',
              style:
                  TextStyles.mont_semibold(color: Colors.white, fontSize: 12),
            ),
            onPressed: (() {
              workoutDataRepo.deleteExerciseListItem(
                  itemIndex: context
                      .read<WorkoutProvider>()
                      .exerciseListDB
                      .indexOf(midExerciseRestObject),
                  selectedWorkoutKey: workProv.selectedWorkout!.key);
              Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          home_page()),
                  (route) => false);
            }))
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

  Widget buildExerciseTile(
      {required ExerciseListItem exerciseObject,
      required String exerciseName,
      required int set_count,
      required int mid_set_rest,
      required String mid_set_rest_timetype,
      required String execution_type,
      int? reps,
      int? duration,
      String? duration_timetype}) {
    WorkoutProvider workProv = context.read<WorkoutProvider>();
    return FocusedMenuHolder(
      onPressed: (() {}),
      menuItems: [
        FocusedMenuItem(
            trailingIcon: Icon(
              Icons.edit,
              size: 25,
              color: Colors.white,
            ),
            backgroundColor: green,
            title: Text(
              'Edit',
              style:
                  TextStyles.mont_semibold(color: Colors.white, fontSize: 12),
            ),
            onPressed: (() {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => add_exercise_page(
                            exerciseListItem: exerciseObject,
                          )));
            })),
        FocusedMenuItem(
            trailingIcon: Icon(
              Icons.delete,
              size: 25,
              color: Colors.white,
            ),
            backgroundColor: Colors.red,
            title: Text(
              'Delete',
              style:
                  TextStyles.mont_semibold(color: Colors.white, fontSize: 12),
            ),
            onPressed: (() {
              workoutDataRepo.deleteExerciseListItem(
                  itemIndex: context
                      .read<WorkoutProvider>()
                      .exerciseListDB
                      .indexOf(exerciseObject),
                  selectedWorkoutKey: workProv.selectedWorkout!.key);
            }))
      ],
      child: Container(
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
      ),
    );
  }

  showDeleteWorkoutConfirmation() {
    showDialog(
        context: context,
        builder: (context) {
          // WorkoutProvider workProv = context.read()<WorkoutProvider>();
          return AlertDialog(
            backgroundColor: lightGray,
            title: Text(
              'Delete Workout Routine',
              style: TextStyles.mont_bold(color: Colors.white, fontSize: 14),
            ),
            content: Text(
              'Are you sure you want to delete ${context.read<WorkoutProvider>().selectedWorkout!.name}?',
              style: TextStyles.mont_regular(color: Colors.white, fontSize: 14),
            ),
            actions: [
              TextButton(
                  onPressed: (() {
                    Navigator.pop(context);
                  }),
                  child: Text(
                    'Cancel',
                    style: TextStyles.mont_bold(color: green),
                  )),
              TextButton(
                  onPressed: (() {
                    workoutDataRepo.deleteWorkout(
                        context.read<WorkoutProvider>().selectedWorkout!,
                        context.read<WorkoutProvider>());
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }),
                  child: Text(
                    'Confirm',
                    style: TextStyles.mont_bold(color: green),
                  )),
            ],
          );
        });
  }

  void showUpdateMidExerciseRest(ExerciseListItem item) {
    midExerciseRestDurationController.text =
        item.midexercise_rest_duration.toString();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: lightGray,
          title: Text(
            'Add Mid-Exercise Rest',
            style: TextStyles.mont_bold(color: Colors.white, fontSize: 14),
          ),
          content: StatefulBuilder(
            builder: (context, timetTypeState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: midExerciseRestDurationController,
                      cursorColor: green,
                      decoration: InputDecoration(
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
                onPressed: (() {
                  WorkoutProvider workProv = context.read<WorkoutProvider>();
                  workoutDataRepo.updateMidExerciseRest(
                      itemToBeUpdated: item,
                      selectedWorkoutKey: workProv.selectedWorkout!.key,
                      workProv: workProv,
                      durationTimeType: selectedTimeType,
                      duration:
                          int.parse(midExerciseRestDurationController.text));

                  midExerciseRestDurationController.clear();
                  Navigator.pop(context);
                }),
                child: Text(
                  'Confirm',
                  style: TextStyles.mont_bold(color: green),
                )),
          ],
        );
      },
    );
  }
}
