import 'package:flutter/cupertino.dart';
import 'package:student_attendance/models/student_model.dart';

class AttendanceProvider extends ChangeNotifier {
  // =====================
  // Selected Date
  // =====================
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // =====================
  // Dummy Student List
  // =====================
  final List<Student> students = [
    Student(roll: 1, name: 'Rahul', status: 'P'),
    Student(roll: 2, name: 'Riya', status: 'P'),
    Student(roll: 3, name: 'Tripathi', status: 'P'),
  ];

  // =====================
  // Attendance Maps
  // =====================
  Map<String, List<Student>> dailyAttendance = {};
  Map<String, Map<String, String>> studentAttendanceHistory = {};

  // =====================
  // Format date as yyyy-MM-dd
  // =====================
  String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // =====================
  // Mark all students present for selected date
  // =====================
  void markAllPresent(DateTime date) {
    String dateKey = formatDate(date);
    List<Student> todayList = [];

    for (var s in students) {
      final student = Student(roll: s.roll, name: s.name, status: 'P');
      todayList.add(student);

      // Update student history
      studentAttendanceHistory.update(
        s.name,
            (existing) => {...existing, dateKey: 'P'},
        ifAbsent: () => {dateKey: 'P'},
      );
    }

    dailyAttendance[dateKey] = todayList;
    notifyListeners();
  }

  // =====================
  // Load attendance for selected date
  // =====================
  List<Student> loadAttendance(DateTime date) {
    String dateKey = formatDate(date);
    return dailyAttendance[dateKey] ?? [];
  }

  // =====================
  // Toggle P/A for a student on a date
  // =====================
  void toggleAttendance(String name, DateTime date) {
    String dateKey = formatDate(date);

    final studentsForDate = dailyAttendance[dateKey];
    if (studentsForDate != null) {
      for (int i = 0; i < studentsForDate.length; i++) {
        if (studentsForDate[i].name == name) {
          String newStatus = studentsForDate[i].status == 'P' ? 'A' : 'P';
          studentsForDate[i] = Student(
            roll: studentsForDate[i].roll,
            name: name,
            status: newStatus,
          );

          // Update student history
          studentAttendanceHistory[name]?[dateKey] = newStatus;
          break;
        }
      }
    }

    notifyListeners();
  }

  // =====================
  // Delete attendance for a date
  // =====================
  void deleteAttendance(DateTime date) {
    String dateKey = formatDate(date);
    dailyAttendance.remove(dateKey);

    for (final history in studentAttendanceHistory.values) {
      history.remove(dateKey);
    }
    notifyListeners();
  }
}
