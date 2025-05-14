import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Set<DateTime> workingDays;

  const AttendanceCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.workingDays,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      focusedDay: selectedDate,
      firstDay: DateTime(2021, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      selectedDayPredicate: (day) => isSameDay(day, selectedDate),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blue.shade900,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, _) {
          final isMarked = workingDays.any((d) => isSameDay(d, day));
          if (isMarked) {
            return Positioned(
              bottom: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return null;
        },
      ),
      onDaySelected: (date, _) {
        onDateSelected(date);
      },
    );
  }
}
