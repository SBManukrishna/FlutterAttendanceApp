import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_attendance/models/student_model.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance/providers/attendance_provider.dart';

class StudentAttendancePage extends StatelessWidget {
  final Student student;

  const StudentAttendancePage(this.student, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attendanceMap = context
        .read<AttendanceProvider>()
        .studentAttendanceHistory[student.name] ??
        {};

    int presentCount = attendanceMap.values.where((v) => v == 'P').length;
    int absentCount = attendanceMap.values.where((v) => v == 'A').length;
    int total = presentCount + absentCount;

    double percentage =
    total == 0 ? 0 : (presentCount / total * 100).toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${student.name} Attendance'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildPieChart(presentCount, absentCount, percentage),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: DateTime.now(),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: TextStyle(color: Colors.white),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final key = _formatDate(day);
                    final status = attendanceMap[key];
                    if (status == null) return null;

                    Color bgColor = status == 'P' ? Colors.green : Colors.red;

                    return Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon:
                  Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                  Icon(Icons.chevron_right, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildPieChart(int present, int absent, double percent) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: present.toDouble(),
                      title: '',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: absent.toDouble(),
                      title: '',
                      radius: 50,
                    ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percent.toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    Text(
                      'Present',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Present: $present   Absent: $absent   Total: ${present + absent}',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
