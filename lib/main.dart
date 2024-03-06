import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_app_idk/models/ExerciseListItem.dart';
import 'package:workout_app_idk/models/ExerciseSequenceItem.dart';
import 'package:workout_app_idk/models/Workout_model.dart';
import 'package:workout_app_idk/providers/page_provider.dart';
import 'package:workout_app_idk/providers/workout_provider.dart';
import 'package:workout_app_idk/screens/test.dart';
import 'screens/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main()async{
  
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(ExerciseListItemAdapter());
  Hive.registerAdapter(ExerciseSequenceItemAdapter());
  await Hive.openBox<Workout>('workouts');
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<WorkoutProvider>(create: (context) => WorkoutProvider(),),
        Provider<page_provider>(create: (context) => page_provider(),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GymPulse',
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home:  home_page(),
      ),
    );
  }
}
