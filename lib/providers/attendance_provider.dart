import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/student_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final List<Student> students = [
    Student(roll: 1, name: 'Rahul', status: 'P'),
    Student(roll: 2, name: 'Riya', status: 'P'),
    Student(roll: 3, name: 'Tripathi', status: 'P'),
  ];

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void markAllPresent(DateTime date) async {
    final dateKey = formatDate(date);
    final dailyBox = Hive.box<List>('dailyAttendance');
    final historyBox = Hive.box<Map>('studentAttendanceHistory');

    final todayList = students.map((s) => Student(
      roll: s.roll,
      name: s.name,
      status: 'P',
    )).toList();

    dailyBox.put(dateKey, todayList);

    for (var student in todayList) {
      final existing = historyBox.get(student.name, defaultValue: {}) as Map;
      existing[dateKey] = 'P';
      historyBox.put(student.name, existing);
    }

    notifyListeners();
  }

  List<Student> loadAttendance(DateTime date) {
    final dateKey = formatDate(date);
    final dailyBox = Hive.box<List>('dailyAttendance');
    final loaded = dailyBox.get(dateKey);

    if (loaded != null) {
      return List<Student>.from(loaded.cast<Student>());
    }
    return [];
  }

  void toggleAttendance(String name, DateTime date) async {
    final dateKey = formatDate(date);
    final dailyBox = Hive.box<List>('dailyAttendance');
    final historyBox = Hive.box<Map>('studentAttendanceHistory');

    List<Student> studentsForDate = List<Student>.from(dailyBox.get(dateKey, defaultValue: [])!.cast<Student>());

    for (int i = 0; i < studentsForDate.length; i++) {
      if (studentsForDate[i].name == name) {
        final newStatus = studentsForDate[i].status == 'P' ? 'A' : 'P';
        studentsForDate[i] = Student(
          roll: studentsForDate[i].roll,
          name: name,
          status: newStatus,
        );

        final existing = historyBox.get(name, defaultValue: {}) as Map;
        existing[dateKey] = newStatus;
        historyBox.put(name, existing);

        break;
      }
    }

    dailyBox.put(dateKey, studentsForDate);
    notifyListeners();
  }

  void deleteAttendance(DateTime date) async {
    final dateKey = formatDate(date);
    final dailyBox = Hive.box<List>('dailyAttendance');
    final historyBox = Hive.box<Map>('studentAttendanceHistory');

    dailyBox.delete(dateKey);

    for (final key in historyBox.keys) {
      final history = historyBox.get(key, defaultValue: {}) as Map;
      history.remove(dateKey);
      historyBox.put(key, history);
    }

    notifyListeners();
  }
}
