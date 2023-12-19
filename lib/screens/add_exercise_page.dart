import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:workout_app_idk/providers/workout_provider.dart';
import '../models/ExerciseListItem.dart';
import 'package:provider/provider.dart';
import 'package:workout_app_idk/services/workout_service.dart';
import 'package:workout_app_idk/themes/TextStyles.dart';

class add_exercise_page extends StatefulWidget {
  ExerciseListItem? exerciseListItem;

  String? selectedWorkoutKey;
  String? selectedWorkoutName;
  String? selectedExecutionType;
  String? exerciseName;
  int? set_count;
  int? reps;
  String? selectedDurationTimeType;
  int? exerciseDuration;
  int? midSetRestDuration;
  String? selectedRestTimeType;

  add_exercise_page(
      {ExerciseListItem? this.exerciseListItem}
      );

  @override
  State<add_exercise_page> createState() => _add_exercise_pageState();
}

class _add_exercise_pageState extends State<add_exercise_page> {
  Uuid uuid = Uuid();
  Color green = Color(0xff00c298);
  Color lightGray = Color(0xff222222);
  Color lighterGray = Color.fromARGB(255, 58, 58, 58);
  int widgetRebuilder = 1;
  String? selectedExecutionType = 'Reps';
  String? selectedDurationTimeType = 'sec';
  String? selectedRestTimeType = 'min';
  final exerciseNameController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();
  final exerciseDurationController = TextEditingController();
  final midSetRestDurationController = TextEditingController();
  final List<String> executionTypes = ['Reps', 'Duration'];
  final List<String> timeTypes = ['sec', 'min'];
  WorkoutDataRepository workoutDataRepository = WorkoutDataRepository();

  @override
  void initState() {
    super.initState();
    
    if(widget.exerciseListItem!=null){
      widget.selectedWorkoutKey = context.read<WorkoutProvider>().selectedWorkout!.key;
      widget.selectedWorkoutName = context.read<WorkoutProvider>().selectedWorkout!.name;
      widget.selectedExecutionType = widget.exerciseListItem!.execution_type;
      widget.exerciseName = widget.exerciseListItem!.exerciseName;
      widget.set_count = widget.exerciseListItem!.set_count;
      widget.reps = widget.exerciseListItem!.reps;
      widget.selectedDurationTimeType = widget.exerciseListItem!.exercise_duration_timetype;
      widget.exerciseDuration = widget.exerciseListItem!.exercise_duration;
      widget.midSetRestDuration = widget.exerciseListItem!.midset_rest_duration;
      widget.selectedRestTimeType = widget.exerciseListItem!.midset_rest_duration_timetype;
      selectedExecutionType = widget.selectedExecutionType!;
      selectedRestTimeType = widget.selectedRestTimeType!;
      exerciseNameController.text = widget.exerciseName!;
      setsController.text = widget.set_count.toString();
      midSetRestDurationController.text = widget.midSetRestDuration.toString();

      if(widget.exerciseListItem!.execution_type=='Duration'){
      selectedDurationTimeType = widget.selectedDurationTimeType;
      exerciseDurationController.text = widget.exerciseDuration.toString();
      }
      else{
        repsController.text = widget.reps.toString();
        print("REPS SYA");
      }
      
    }
    else{
      print("exercise is null!");
    }
  }

  @override
  void dispose() {
    Hive.box('workouts').close();
    exerciseNameController.dispose();
    setsController.dispose();
    repsController.dispose();
    exerciseDurationController.dispose();
    midSetRestDurationController.dispose();
    super.dispose();
  }

  void addExercise(WorkoutProvider workoutProvider) {
    print(
        'EXERCISELIST BEFORE ADDING: ${context.read<WorkoutProvider>().exerciseListDB}');
    String key = workoutProvider.selectedWorkout!.key;
    workoutProvider.modifyExerciseList(
        itemToBeUpdated: (widget.exerciseListItem!=null) ? widget.exerciseListItem : null,
        selectedWorkoutKey: key,
        selectedWorkoutName: workoutProvider.selectedWorkout!.name,
        exerciseName: exerciseNameController.text.trim(),
        set_count: int.parse(setsController.text.trim()),
        reps: (repsController.text.trim() == '')
            ? null
            : int.parse(repsController.text.trim()),
        exerciseDuration: (exerciseDurationController.text.trim() == '')
            ? null
            : int.parse(exerciseDurationController.text.trim()),
        midSetRestDuration: int.parse(midSetRestDurationController.text.trim()),
        selectedDurationTimeType: selectedDurationTimeType,
        selectedExecutionType: selectedExecutionType,
        selectedRestTimeType: selectedRestTimeType);
    print(
        'EXERCISELIST AFTER ADDING: ${context.read<WorkoutProvider>().exerciseListDB}');
  }

  List<DropdownMenuItem<String>> buildMenuItem(List<String> list) {
    return list
        .map((item) => DropdownMenuItem(
              child: Text(item),
              value: item,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: lightGray,
            appBar: AppBar(
              leading: Container(
                height: double.infinity,
                width: 65,
                child: InkWell(
                    onTap: (() {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.red,
                    )),
              ),
              actions: [
                Container(
                  height: double.infinity,
                  width: 65,
                  child: InkWell(
                    onTap: (() async {
                      addExercise(workoutProvider);
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }),
                    child: Icon(
                      Icons.check,
                      size: 25,
                      color: green,
                    ),
                  ),
                )
              ],
              backgroundColor: lighterGray,
              title: Text(
                'Add Exercise',
                style:
                    TextStyles.mont_regular(color: Colors.white, fontSize: 18),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    // Text(workoutProvider.selectedWorkout!.key),
                    TextField(
                      cursorColor: green,
                      controller: exerciseNameController,
                      style: TextStyles.mont_regular(
                          fontSize: 14, color: Colors.white),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: green)),
                        labelStyle: TextStyles.mont_regular(
                            fontSize: 14, color: Colors.grey),
                        labelText: "Exercise Name",
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      cursorColor: green,
                      controller: setsController,
                      style: TextStyles.mont_regular(
                          fontSize: 14, color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: green)),
                          labelStyle: TextStyles.mont_regular(
                              fontSize: 14, color: Colors.grey),
                          labelText: "Sets"),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text("Execution Type",
                        style: TextStyles.mont_regular(
                            fontSize: 14, color: Colors.white)),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.grey.shade700, width: 1.3)),
                      child: DropdownButton(
                        underline: SizedBox(),
                        dropdownColor: lightGray,
                        // style: TextStyle(fontSize: 14, color: Colors.black),
                        isExpanded: true,
                        isDense: true,
                        style: TextStyles.mont_regular(
                            fontSize: 14, color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        padding: EdgeInsets.all(10),
                        items: buildMenuItem(executionTypes),
                        value: selectedExecutionType,
                        onChanged: (newValue) {
                          if (newValue == 'Duration') {
                            repsController.clear();
                          } else {
                            exerciseDurationController.clear();
                          }
                          setState(() {
                            selectedExecutionType = newValue!;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    (selectedExecutionType == 'Reps')
                        ? TextField(
                            cursorColor: green,
                            controller: repsController,
                            style: TextStyles.mont_regular(
                                fontSize: 14, color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: green)),
                              labelStyle: TextStyles.mont_regular(
                                  fontSize: 14, color: Colors.grey),
                              labelText: "Reps",
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: exerciseDurationController,
                                  style: TextStyles.mont_regular(
                                      fontSize: 14, color: Colors.white),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: green)),
                                    labelStyle: TextStyles.mont_regular(
                                        fontSize: 14, color: Colors.grey),
                                    labelText: "Duration",
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade700,
                                        width: 1.3)),
                                child: DropdownButton(
                                    borderRadius: BorderRadius.circular(10),
                                    dropdownColor: lightGray,
                                    underline: SizedBox(),
                                    style: TextStyles.mont_regular(
                                        fontSize: 14, color: Colors.white),
                                    padding: EdgeInsets.all(10),
                                    value: selectedDurationTimeType,
                                    items: buildMenuItem(timeTypes),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedDurationTimeType = newValue!;
                                      });
                                    }),
                              )
                            ],
                          ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            cursorColor: green,
                            controller: midSetRestDurationController,
                            style: TextStyles.mont_regular(
                                fontSize: 14, color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: green)),
                                labelStyle: TextStyles.mont_regular(
                                    fontSize: 14, color: Colors.grey),
                                labelText: "Rest Time (Between Sets)"),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade700, width: 1.3),
                              borderRadius: BorderRadius.circular(10)),
                          child: DropdownButton(
                              borderRadius: BorderRadius.circular(10),
                              underline: SizedBox(),
                              dropdownColor: lightGray,
                              style: TextStyles.mont_regular(
                                  fontSize: 14, color: Colors.white),
                              padding: EdgeInsets.all(10),
                              value: selectedRestTimeType,
                              items: buildMenuItem(timeTypes),
                              onChanged: (newVal) {
                                setState(() {
                                  selectedRestTimeType = newVal!;
                                });
                              }),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
