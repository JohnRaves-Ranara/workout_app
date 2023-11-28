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
import 'package:dotted_border/dotted_border.dart';

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

  Color green = Color(0xff00c298);
  Color lightGray = Color(0xff222222);
  Color lighterGray = Color.fromARGB(255, 58, 58, 58);
  WorkoutDataRepository workoutDataRepository = WorkoutDataRepository();
  int widgetRebuilder = 1;
  PageController pc = PageController();

  @override
  void initState() {
    pageIndex = 0;
    WorkoutProvider prov = Provider.of<WorkoutProvider>(context, listen: false);
    workoutBoxRef = Hive.box<Workout>('workouts');
    workouts = workoutBoxRef.values.toList();
    //NEED FIX FOR FIRST TIME USER SINCE EMPTY PA ANG DATABASE. CANT SELECT WORKOUT.
    if (!prov.isworkoutDBEmpty) {
      print("DILI EMPTY ANG DB SINCE THE BEGINNING");
      prov.selectWorkout(workouts[0]);
    }
  }

  @override
  void dispose() {
    Hive.box('workouts').close();
    super.dispose();
  }

  showWorkoutListModalSheet(List<Workout> workouts) {
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
            height: 400,
            child: ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                return Ink(
                  height: 65,
                  child: InkWell(
                    onTap: (() {
                      setState(() {
                        pc.animateToPage(index,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeIn);
                      });
                      Navigator.pop(context);
                    }),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          workouts[index].name,
                          style: TextStyles.mont_semibold(color: Colors.white),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.edit,
                              size: 22,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Icon(
                              Icons.delete,
                              size: 22,
                              color: Colors.white,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  showAddExerciseListItemModalSheet() {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        context: context,
        builder: (context) {
          return Container(
            height: 130,
            // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                Ink(
                  // color: Color(0xff00c298),
                  height: 60,
                  child: InkWell(
                    onTap: (() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => add_exercise_page()));
                    }),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Exercise',
                            style: TextStyles.mont_semibold(
                                color: Colors.white, fontSize: 14)),
                        Icon(
                          Icons.fitness_center,
                          size: 25,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: (() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => add_midexerciserest_page()));
                    // setState(() {
                    //   isAddingRest = true;
                    // });
                    // Navigator.pop(context);
                  }),
                  child: Container(
                    // color: Colors.amber,
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Mid-Exercise Rest',
                            style: TextStyles.mont_semibold(
                                color: Colors.white, fontSize: 14)),
                        Icon(
                          Icons.access_alarm,
                          size: 25,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  String formatReps(int rep) {
    if (rep == 1) {
      return 'Rep';
    }
    return 'Reps';
  }

  void addWorkoutDialog(WorkoutProvider workProv) {
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
                    Navigator.pop(context);
                  }),
                  child: Text(
                    'Cancel',
                    style: TextStyles.mont_bold(color: green),
                  )),
              TextButton(
                  onPressed: (() {
                    Workout newlyAddedWorkout = workProv.addWorkout(workoutNameController.text.trim());
                    // pc.animateToPage(workProv.workoutDB.indexOf(newlyAddedWorkout), duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                    workProv.selectWorkout(newlyAddedWorkout);
                    // List<Workout> workouts = workoutBoxRef.values.toList().cast<Workout>();
                    // pc.jumpTo(workouts.indexOf(z)+.0);
                    workoutNameController.clear();
                    setState(() {
                      print("dasdasdaszzz");
                      widgetRebuilder = 1;
                    });
                    
                    Navigator.pop(context);
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
          GestureDetector(
            onTap: (() {
              print(
                  'LENGTH OF AFTER before DB: ${workoutBoxRef.values.toList().length} ${workoutBoxRef.values.toList()[0].name}');
              workoutProvider.clearDB();
              print(workoutProvider.workoutDB);

              print(
                  'LENGTH OF AFTER CLEARING DB: ${workoutBoxRef.values.toList().length}');

              setState(() {
                widgetRebuilder = 1;
              });
            }),
            child: Container(
              height: 50,
              width: 50,
              color: Colors.red,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          Ink(
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(15)),
            height: 50,
            width: MediaQuery.of(context).size.width * 0.5,
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
          Ink(
            decoration: BoxDecoration(
                color: green, borderRadius: BorderRadius.circular(15)),
            height: 50,
            width: MediaQuery.of(context).size.width * 0.23,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: (() {
                addWorkoutDialog(workoutProvider);
              }),
              child: Icon(
                Icons.add,
                size: 20,
                color: Colors.black,
              ),
            ),
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
                    } else {
                      return GestureDetector(
                        onTap: (() {
                          print(currentItem.type);
                        }),
                        child: buildMidExerciseRestTile(
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
            GestureDetector(
              onTap: (() {
                showAddExerciseListItemModalSheet();
              }),
              child: Container(
                height: double.infinity,
                width: 70,
                // color: Colors.blue,
                child: Icon(
                  Icons.add_circle,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => play_exercises_page()));
              }),
              child: Container(
                // color: Colors.blue,
                height: double.infinity,
                width: 70,
                child: Icon(
                  Icons.play_arrow,
                  size: 20,
                  color: Colors.white,
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
                      addWorkoutDialog(workoutProvider);
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
                  // workoutProvider.selectWorkout(workoutProvider.selectedWorkout ?? workoutProvider.workoutDB[0]);
                  printExerciseList();
                  return listViewContent(workoutProvider);
                }
              }),
            ),
          );
        });
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
