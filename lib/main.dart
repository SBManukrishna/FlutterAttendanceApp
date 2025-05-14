import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/student_model.dart';
import 'providers/attendance_provider.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(StudentAdapter());
  await Hive.openBox<List>('dailyAttendance');
  await Hive.openBox<Map>('studentAttendanceHistory');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AttendanceProvider(),
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}
