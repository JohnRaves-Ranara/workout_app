import 'package:flutter/material.dart';
import 'package:workout_app_idk/models/ExerciseListItem.dart';
import 'package:workout_app_idk/models/ExerciseSequenceItem.dart';
import 'package:workout_app_idk/providers/page_provider.dart';
import 'package:workout_app_idk/providers/workout_provider.dart';
import 'package:provider/provider.dart';
import 'package:workout_app_idk/models/Workout_model.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:workout_app_idk/themes/TextStyles.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_tts/flutter_tts.dart';

class play_exercises_page extends StatefulWidget {
  const play_exercises_page({super.key});

  @override
  State<play_exercises_page> createState() => _play_exercises_pageState();
}

class _play_exercises_pageState extends State<play_exercises_page> {
  late Box<Workout> workoutBoxRef;
  late int remainingSeconds;
  Timer? timer;
  List<ExerciseSequenceItem> workoutSequence = [];
  // GlobalKey<ExpandableBottomSheetState> key = new GlobalKey();
  ItemScrollController sc = ItemScrollController();
  Timer? scrollTimer;
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    workoutBoxRef = Hive.box('workouts');
    print("dasd");
    buildSequence();
    print("daazz");
    ExerciseSequenceItem firstItem = workoutSequence[0];
    page_provider prov = Provider.of<page_provider>(context, listen: false);
    if (firstItem.duration_timetype == 'min') {
      setState(() {
        remainingSeconds = firstItem.duration! * 60;
      });
    } else {
      setState(() {
        remainingSeconds = firstItem.duration!;
      });
    }
    startTimer(prov, prov.page!);

    prov.changePage(0);
  }

  void buildSequence() {
    WorkoutProvider prov = Provider.of<WorkoutProvider>(context, listen: false);
    print("wajud");
    String key = prov.selectedWorkout!.key;
    print("keyget");
    var selectedWorkout = workoutBoxRef.get(key);
    List<ExerciseListItem> exerciseList_fromDB = selectedWorkout!.exerciseList;
    workoutSequence.add(ExerciseSequenceItem()
      ..type = 'Ready Timer'
      ..duration = 10
      ..duration_timetype = 'sec');

    for (ExerciseListItem item in exerciseList_fromDB) {
      int setNumberCounter = 1;
      if (item.type == 'Exercise') {
        while (setNumberCounter <= item.set_count!) {
          if (item.execution_type == 'Reps') {
            workoutSequence.add(ExerciseSequenceItem()
              ..type = 'Exercise'
              ..execution_type = 'Reps'
              ..exercise_name = item.exerciseName
              ..set_number = setNumberCounter
              ..reps = item.reps
              ..sets = item.set_count);
          } else {
            workoutSequence.add(ExerciseSequenceItem()
              ..type = 'Exercise'
              ..execution_type = 'Duration'
              ..exercise_name = item.exerciseName
              ..set_number = setNumberCounter
              ..duration = item.exercise_duration
              ..duration_timetype = item.exercise_duration_timetype
              ..sets = item.set_count);
          }

          if (setNumberCounter != item.set_count) {
            workoutSequence.add(ExerciseSequenceItem()
              ..type = 'Mid-Set Rest'
              ..duration = item.midset_rest_duration
              ..duration_timetype = item.midset_rest_duration_timetype);
          }
          setNumberCounter++;
        }
      } else {
        workoutSequence.add(ExerciseSequenceItem()
          ..type = 'Mid-Exercise Rest'
          ..duration = item.midexercise_rest_duration
          ..duration_timetype = item.midexercise_rest_duration_timetype);
      }
    }
  }

  String formatTime(int time) {
    int minutes = time ~/ 60;
    int seconds = time % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void verifyNext(page_provider prov, int currentPage) {
    setState(() {
      if (currentPage != workoutSequence.length - 1) {
        timer?.cancel();
        ExerciseSequenceItem nextItem = workoutSequence[currentPage + 1];
        if ((nextItem.type == 'Exercise' &&
                nextItem.execution_type == 'Duration') ||
            (nextItem.type != 'Exercise')) {
          print("1");
          if (nextItem.duration_timetype == 'min') {
            remainingSeconds = nextItem.duration! * 60;
          } else {
            remainingSeconds = nextItem.duration!;
          }
          print("2");
          prov.changePage(currentPage + 1);
          startTimer(prov, prov.page!);
          scrollToCurrent();
        } else {
          print("3");
          timer!.cancel();
          prov.changePage(currentPage + 1);
          scrollToCurrent();
        }
      }
      widgetRebuilder = 1;
    });
  }

  void startTimer(page_provider prov, int currentPage) {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds = remainingSeconds - 1;
          if (prov.page! != workoutSequence.length - 1) {
            ExerciseSequenceItem nextItem = workoutSequence[prov.page! + 1];
            if (remainingSeconds == 9) {
              speak(((nextItem.type != 'Exercise')
                  ? 'Up next, ${nextItem.type}'
                  : 'Up next, ${nextItem.exercise_name} ${formatSetName(nextItem.set_number!)} set'));
            }
          }
          if (remainingSeconds <= 5) {
            speak(remainingSeconds.toString());
          }
        } else {
          timer.cancel();
          verifyNext(prov, currentPage);
          widgetRebuilder = 1;
          scrollToCurrent();
        }
      });
    });
  }

  // void replayTimer(ExerciseSequenceItem currentItem) {
  //   setState(() {
  //     if (currentItem.duration_timetype == 'min') {
  //       remainingSeconds = currentItem.duration! * 60;
  //     } else {
  //       remainingSeconds = currentItem.duration!;
  //     }
  //   });
  // }

  void scrollToCurrent() {
    page_provider prov = Provider.of<page_provider>(context, listen: false);
    int page = prov.page!;
    sc.scrollTo(
      index: page,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String formatSetName(int num) {
    String setNum = num.toString();
    String lastNumber = setNum[setNum.length - 1];
    if (lastNumber == '1') {
      return setNum.replaceAll(setNum[setNum.length - 1], '1st');
    } else if (lastNumber == '2') {
      return setNum.replaceAll(setNum[setNum.length - 1], '2nd');
    } else if (lastNumber == '3') {
      return setNum.replaceAll(setNum[setNum.length - 1], '3rd');
    } else {
      return setNum.replaceAll(
          setNum[setNum.length - 1], '${setNum[setNum.length - 1]}th');
    }
  }

  String formatReps(int rep) {
    if (rep == 1) return 'rep';
    return 'rep';
  }

  void startScrollTimer() {
    page_provider prov = Provider.of<page_provider>(context, listen: false);
    scrollTimer = Timer(Duration(seconds: 1), scrollToCurrent);
  }

  void cancelScrollTimer() {
    scrollTimer?.cancel();
  }

  Future speak(String text) async {
    await FlutterTts().setLanguage("en-US");
    await FlutterTts().speak(text);
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
      if (isMuted) {
        FlutterTts().setVolume(0.0); // Mute TTS
      } else {
        FlutterTts().setVolume(1.0); // Unmute TTS
      }
    });
  }

  //since entire widget tree cannot be rebuilt when you change
  //a variable (page) in provider (page_provider)
  //this is a (dirty) fix for problem: Exercise of execution_type = 'Reps' does not
  //turn blue after proceeding from a timed object (rest or timed exercise)
  //since in order to make it blue you need to rebuild the entire widget tree
  //rest and timed exercise does this by using startTimer(), which sets a new
  //value for remainingSeconds (setState)
  //which is why every page change every tick of the timer. I call setState on this variable to rebuild
  //the entire widget tree
  late int widgetRebuilder;

  @override
  Widget build(BuildContext context) {
    return Consumer<page_provider>(
      builder: (context, pageProvider, child) {
        int currentPage = pageProvider.page!;
        ExerciseSequenceItem currentItem = workoutSequence[currentPage];
        print("current page: ${currentPage}");
        bool isCurrentItemReps = currentItem.type == 'Exercise' &&
            currentItem.execution_type == 'Reps';
        print('IS CURRENT ITEM REPS: ${isCurrentItemReps}');
        bool isRunning = timer == null ? false : timer!.isActive;
        WorkoutProvider workProv =
            Provider.of<WorkoutProvider>(context, listen: false);
        String selectedWorkoutName = workProv.selectedWorkout!.name;

        return SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  actions: [
                    GestureDetector(
                      onTap: ((){
                        toggleMute();
                      }),
                      child: Container(
                        height: double.infinity,
                        padding: EdgeInsets.only(right: 15),
                        child: 
                        (!isMuted)
                            ? Icon(
                                Icons.volume_up,
                                size: 25,
                                color: Colors.white,
                              )
                            : 
                            Icon(
                                Icons.volume_off_rounded,
                                size: 25,
                                color: Colors.white,
                              ),
                      ),
                    )
                  ],
                  centerTitle: true,
                  title: Text(
                    selectedWorkoutName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyles.mont_semibold(
                        color: Colors.white, fontSize: 18),
                  ),
                  // toolbarHeight: 50,
                  backgroundColor: Colors.transparent,
                  leading: GestureDetector(
                    onTap: (() {
                      Navigator.pop(context);
                    }),
                    child: Icon(
                      Icons.close,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
                backgroundColor: Color(0xff0a0a0a),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularPercentIndicator(
                      animateFromLastPercent: true,
                      animation: true,
                      animationDuration: 300,
                      center: buildPercentIndicatorCenterWidget(
                          currentItem, pageProvider),
                      radius: MediaQuery.of(context).size.height * 0.2,
                      lineWidth: 15,
                      percent: ((currentItem.type == 'Exercise' &&
                                  currentItem.execution_type == 'Duration') ||
                              (currentItem.type != 'Exercise'))
                          ? (currentItem.duration_timetype == 'min')
                              ? remainingSeconds / (currentItem.duration! * 60)
                              : remainingSeconds / currentItem.duration!
                          : 1,
                      progressColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    buildButtons(pageProvider, isRunning, isCurrentItemReps),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(15)),
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification.metrics.pixels <
                                notification.metrics.maxScrollExtent) {
                              cancelScrollTimer();
                              startScrollTimer();
                            }

                            return false;
                          },
                          child: ScrollablePositionedList.builder(
                            physics: RangeMaintainingScrollPhysics(),
                            itemScrollController: sc,
                            itemCount: workoutSequence.length,
                            itemBuilder: (context, index) {
                              ExerciseSequenceItem currentItem =
                                  workoutSequence[index];
                              int? duration;
                              String? duration_timetype;
                              int? set_number;
                              String? exercise_name;
                              int? reps;
                              Color? color;
                              String? type;
                              // if(remainingSeconds < 10 || (currentItem.type=='Exercise' && currentItem.execution_type=='Reps')){
                              //   FlutterTts().speak('Coming up, ${workoutSequence[currentPage+1].type}');

                              // }
                              if (currentItem.type == 'Exercise') {
                                if (currentItem.execution_type == 'Duration') {
                                  duration = currentItem.duration!;
                                  duration_timetype =
                                      currentItem.duration_timetype;
                                } else {
                                  reps = currentItem.reps;
                                }
                                type = 'Exercise';
                                set_number = currentItem.set_number;
                                exercise_name = currentItem.exercise_name;
                                color = Color(0xff4fa2fe);
                              } else if (currentItem.type == 'Mid-Set Rest') {
                                type = 'Mid-Set Rest';
                                color = Color.fromARGB(255, 223, 137, 45);
                                duration_timetype =
                                    currentItem.duration_timetype;
                                duration = currentItem.duration;
                              } else if (currentItem.type ==
                                  'Mid-Exercise Rest') {
                                type = 'Mid-Exercise Rest';
                                color = Color(0xff00c298);
                                duration_timetype =
                                    currentItem.duration_timetype;
                                duration = currentItem.duration;
                              } else {
                                type = 'Ready Timer';
                                color = Color.fromARGB(255, 233, 97, 140);
                                duration_timetype =
                                    currentItem.duration_timetype;
                                duration = currentItem.duration;
                              }

                              if (index == pageProvider.page) {
                                print(
                                    'PAGE: ${pageProvider.page!} INDEX: ${index}');
                                if (type == 'Exercise') {
                                  return buildExerciseTile(
                                      true,
                                      color,
                                      exercise_name!,
                                      set_number!,
                                      currentItem.execution_type!,
                                      reps,
                                      duration,
                                      duration_timetype);
                                } else if (type == 'Ready Timer') {
                                  return buildReadyTimerTile(true, type, color,
                                      duration, duration_timetype);
                                } else {
                                  return buildRestTile(true, type, color,
                                      duration, duration_timetype);
                                }
                              } else {
                                if (type == 'Exercise') {
                                  return buildExerciseTile(
                                      false,
                                      null,
                                      exercise_name!,
                                      set_number!,
                                      currentItem.execution_type!,
                                      reps,
                                      duration,
                                      duration_timetype);
                                } else if (type == 'Ready Timer') {
                                  return buildReadyTimerTile(false, type, null,
                                      duration, duration_timetype);
                                } else {
                                  return buildRestTile(false, type, null,
                                      duration, duration_timetype);
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                )));
      },
    );
  }

  Widget buildExerciseTile(
    bool isCurrent,
    Color? color,
    String exercise_name,
    int set_number,
    String execution_type,
    int? reps,
    int? duration,
    String? duration_timetype,
  ) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height * 0.13,
          decoration: BoxDecoration(
              color: (isCurrent) ? color : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(15)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.018,
              ),
              Text(
                exercise_name,
                style: TextStyles.mont_bold(
                    fontSize: 14,
                    color: (isCurrent) ? Colors.white : Colors.black),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: (isCurrent)
                          ? Colors.amber.shade300
                          : Colors.grey.shade900,
                    ),
                    padding: EdgeInsets.all(5),
                    child: Center(
                      child: Text(
                        formatSetName(set_number),
                        style: TextStyles.mont_bold(
                            fontSize: 14,
                            color: (isCurrent) ? Colors.black : Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Set',
                    style: TextStyles.mont_regular(
                        fontSize: 14, color: Colors.black),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[900]),
                    child: Center(
                      child: Text(
                        (execution_type == 'Reps') ? '${reps}' : '${duration}',
                        // '4 x 60 Sec',
                        style: TextStyles.mont_bold(
                            fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    (execution_type == 'Reps' && reps == 1)
                        ? 'Rep'
                        : (execution_type == 'Reps' && reps! > 1)
                            ? 'Reps'
                            : "${duration_timetype}",
                    style: TextStyles.mont_regular(
                        fontSize: 14, color: Colors.black),
                  )
                ],
              )
            ],
          )),
    );
  }

  Widget buildRestTile(bool isCurrent, String type, Color? color, int? duration,
      String? duration_timetype) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
          height: MediaQuery.of(context).size.height * 0.13,
          decoration: BoxDecoration(
              color: (isCurrent) ? color : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                type,
                style: TextStyles.mont_bold(
                    fontSize: 14,
                    color: (isCurrent) ? Colors.white : Colors.black),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.04,
              ),
              Container(
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[900]),
                      child: Center(
                        child: Text(
                          '${duration}',
                          // '4 x 60 Sec',
                          style: TextStyles.mont_bold(
                              fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "${duration_timetype}",
                      style: TextStyles.mont_regular(
                          fontSize: 14, color: Colors.black),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }

  Widget buildReadyTimerTile(bool isCurrent, String type, Color? color,
      int? duration, String? duration_timetype) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
          height: MediaQuery.of(context).size.height * 0.13,
          decoration: BoxDecoration(
              color: (isCurrent) ? color : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                type,
                style: TextStyles.mont_bold(
                    fontSize: 14,
                    color: (isCurrent) ? Colors.white : Colors.black),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.04,
              ),
              Container(
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey[900]),
                      child: Center(
                        child: Text(
                          '${duration}',
                          // '4 x 60 Sec',
                          style: TextStyles.mont_bold(
                              fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "${duration_timetype}",
                      style: TextStyles.mont_regular(
                          fontSize: 14, color: Colors.black),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }

  Widget buildPercentIndicatorCenterWidget(
      ExerciseSequenceItem currentItem, page_provider prov) {
    page_provider prov = Provider.of<page_provider>(context, listen: false);
    return CircularPercentIndicator(
      animateFromLastPercent: true,
      animation: true,
      animationDuration: 300,
      center: (currentItem.type != 'Exercise')
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${currentItem.type}',
                    style: TextStyles.mont_regular(
                        color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    '${formatTime(remainingSeconds)}',
                    style:
                        TextStyles.mont_bold(color: Colors.white, fontSize: 38),
                  ),
                  Text(
                      (currentItem.type == 'Ready Timer')
                          ? 'Get Ready'
                          : 'Take a breather',
                      style: TextStyles.mont_regular(
                          color: Colors.white, fontSize: 14))
                ],
              ),
            )
          : Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${currentItem.exercise_name}',
                    style: TextStyles.mont_regular(
                        color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    (currentItem.execution_type == 'Duration')
                        ? '${formatTime(remainingSeconds)}'
                        : '${currentItem.reps} ${formatReps(currentItem.reps!)}',
                    style:
                        TextStyles.mont_bold(color: Colors.white, fontSize: 38),
                  ),
                  Text('Set ${currentItem.set_number} of ${currentItem.sets}',
                      style: TextStyles.mont_regular(
                          color: Colors.white, fontSize: 14))
                ],
              ),
            ),
      radius: MediaQuery.of(context).size.height * 0.17,
      lineWidth: 15,
      percent: prov.page! / (workoutSequence.length - 1),
      progressColor: Color(0xff00c298),
      backgroundColor: Colors.transparent,
      circularStrokeCap: CircularStrokeCap.round,
    );
  }

  Widget buildButtons(
      page_provider pageProvider, bool isRunning, bool isCurrentItemReps) {
    if (isCurrentItemReps) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container(
            //   height: 50,
            //   width: 100,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(25),
            //     color: Colors.grey.shade900,
            //   ),
            //   child: Icon(
            //     Icons.close,
            //     size: 30, 
            //     color: Colors.red,
            //   ),
            // ),
            // SizedBox(
            //   width: 20,
            // ),
            GestureDetector(
              onTap: (() async {
                int currentPage = pageProvider.page!;
                print('check clicked! passing page value : ${currentPage}');
                verifyNext(pageProvider, currentPage);
              }),
              child: Container(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xff00c299),
                ),
                child: Icon(
                  Icons.check,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (isRunning)
                ? Ink(
                    height: 50,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey.shade800,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: (() {
                        timer!.cancel();
                        setState(() {
                          isRunning = false;
                        });
                      }),
                      child: Icon(
                        Icons.pause,
                        size: 30,
                        color: Colors.white,
                      ),
                    ))
                : Ink(
                    height: 50,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.grey.shade800,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: (() {
                        startTimer(pageProvider, pageProvider.page!);
                        setState(() {
                          isRunning = false;
                        });
                      }),
                      child: Icon(
                        Icons.play_arrow,
                        size: 30,
                        color: Colors.white,
                      ),
                    )),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: (() async {
                int currentPage = pageProvider.page!;
                print('check clicked! passing page value : ${currentPage}');
                verifyNext(pageProvider, currentPage);
              }),
              child: Container(
                height: 50,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color(0xff00c299),
                ),
                child: Icon(
                  Icons.check,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
