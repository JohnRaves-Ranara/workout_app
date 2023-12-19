import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:workout_app_idk/models/ExerciseListItem.dart';
import 'package:workout_app_idk/themes/TextStyles.dart';
import 'package:workout_app_idk/themes/colors.dart';
import 'package:workout_app_idk/providers/workout_provider.dart';
import 'package:provider/provider.dart';
import 'package:workout_app_idk/screens/home_page.dart';

class ExerciseTile extends StatelessWidget {
   ExerciseListItem? exerciseObject;
   String? exerciseName;
   int? set_count;
   int? mid_set_rest;
   String? mid_set_rest_timetype;
   String? execution_type;
  int? reps;
  int? duration;
  String? duration_timetype;

  ExerciseTile(
    {
      required ExerciseListItem exerciseObject,
      required String exerciseName,
      required int set_count,
      required int mid_set_rest,
      required String mid_set_rest_timetype,
      required String execution_type,
      int? reps,
      int? duration,
      String? duration_timetype});

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: ThemeColor.green,
            title: Text(
              'Edit',
              style: TextStyles.mont_semibold(
                  color: const Color.fromARGB(255, 222, 61, 61), fontSize: 12),
            ),
            onPressed: (() {})),
        FocusedMenuItem(
            trailingIcon: Icon(
              Icons.delete,
              size: 25,
              color: Colors.black,
            ),
            backgroundColor: Colors.red,
            title: Text(
              'Delete',
              style:
                  TextStyles.mont_semibold(color: Colors.white, fontSize: 12),
            ),
            onPressed: (() {
              workProv.deleteExerciseListItem(
                  workProv: workProv,
                  itemIndex: context.read<WorkoutProvider>().exerciseListDB.indexOf(exerciseObject!),
                  selectedWorkoutKey: workProv.selectedWorkout!.key,
                  selectedWorkoutName: workProv.selectedWorkout!.name,
                  oldExerciseList: workProv.exerciseListDB);

              //this is a very dirty fix but it works. Heres the problem and heres how it fixes it:
              //When I delete an exerciselistitem, the widget tree is not rebuilt
              //so changes are not reflected.
              //This code forces the widget tree to rebuilt by navigating to itself. (i use pageroutebuilder to remove push animation)
              Navigator.pushAndRemoveUntil(context, PageRouteBuilder(pageBuilder: (context, animation1, animation2) => home_page()), (route) => false);
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
                color: ThemeColor.lighterGray, borderRadius: BorderRadius.circular(15)),
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
}
