import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_attendance/models/student_model.dart';

class StudentAttendancePage extends StatefulWidget {
  final Student student;

  const StudentAttendancePage(this.student, {Key? key}) : super(key: key);

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  String _filter = 'All';
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final Map historyMap = Hive.box<Map>('studentAttendanceHistory')
        .get(widget.student.name, defaultValue: {}) as Map;

    final filteredMap = _getFilteredMap(historyMap);

    final presentCount = filteredMap.values.where((v) => v == 'P').length;
    final absentCount = filteredMap.values.where((v) => v == 'A').length;
    final total = presentCount + absentCount;

    final percentage = total == 0 ? 0.0 : (presentCount / total * 100);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${widget.student.name} Attendance'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 2),
          _buildFilterControls(context),
          const SizedBox(height: 10),
          _buildPieChart(presentCount, absentCount, percentage),
          const SizedBox(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: DateTime.now(),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: const TextStyle(color: Colors.redAccent),
                  todayDecoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final key = _formatDate(day);
                    final status = filteredMap[key];
                    if (status == null) return null;

                    final bgColor = status == 'P' ? Colors.green : Colors.red;

                    return Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Filters attendance data based on current filter selection
  Map<String, String> _getFilteredMap(Map fullMap) {
    final now = DateTime.now();

    switch (_filter) {
      case 'Week':
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = now;
        return _filterByDateRange(fullMap, start, end);

      case 'Month':
        final start = DateTime(now.year, now.month, 1);
        final end = now;
        return _filterByDateRange(fullMap, start, end);

      case 'Custom':
        if (_customRange != null) {
          return _filterByDateRange(fullMap, _customRange!.start, _customRange!.end);
        }
        return {};

      default:
        return Map<String, String>.from(fullMap);
    }
  }

  Map<String, String> _filterByDateRange(Map fullMap, DateTime start, DateTime end) {
    final filtered = <String, String>{};
    fullMap.forEach((key, value) {
      final date = DateTime.tryParse(key);
      if (date != null && date.isAfter(start.subtract(const Duration(days: 1))) && date.isBefore(end.add(const Duration(days: 1)))) {
        filtered[key] = value;
      }
    });
    return filtered;
  }

  Widget _buildFilterControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<String>(
          dropdownColor: Colors.grey[900],
          value: _filter,
          items: const [
            DropdownMenuItem(value: 'All', child: Text('All', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Week', child: Text('This Week', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Month', child: Text('This Month', style: TextStyle(color: Colors.white))),
            DropdownMenuItem(value: 'Custom', child: Text('Custom Range', style: TextStyle(color: Colors.white))),
          ],
          onChanged: (value) async {
            if (value == 'Custom') {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2023),
                lastDate: DateTime(2030),
                initialDateRange: _customRange ??
                    DateTimeRange(
                      start: DateTime.now().subtract(const Duration(days: 7)),
                      end: DateTime.now(),
                    ),
              );
              if (picked != null) {
                setState(() {
                  _filter = value!;
                  _customRange = picked;
                });
              }
            } else {
              setState(() {
                _filter = value!;
              });
            }
          },
        ),
        const SizedBox(width: 10),
        if (_filter == 'Custom' && _customRange != null)
          Text(
            '${_formatDate(_customRange!.start)} to ${_formatDate(_customRange!.end)}',
            style: const TextStyle(color: Colors.white70),
          ),
      ],
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
          height: 170,
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
                      radius: 40,
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
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const Text(
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
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
