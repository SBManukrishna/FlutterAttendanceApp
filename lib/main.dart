import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance/providers/attendance_provider.dart';
import 'package:student_attendance/ui/home_page.dart';

void main(){
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
