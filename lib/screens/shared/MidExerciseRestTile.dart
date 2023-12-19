import 'package:flutter/material.dart';
import 'package:workout_app_idk/themes/TextStyles.dart';

class MidExerciseRestTile extends StatelessWidget {
  int? duration;
  String? duration_timetype;
  MidExerciseRestTile({required int duration, required String duration_timetype});

  @override
  Widget build(BuildContext context) {
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
}
