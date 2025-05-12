import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance/providers/attendance_provider.dart';
import 'package:student_attendance/models/student_model.dart';
import 'package:student_attendance/ui/student_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> _attendanceList = [];

  void _loadAttendance(BuildContext context, DateTime date) {
    final provider = context.read<AttendanceProvider>();
    final data = provider.loadAttendance(date); // Should return List<Student>

    setState(() {
      _attendanceList = data;  // Assign the loaded list of Student objects to _attendanceList
    });
  }


  @override
  void initState() {
    super.initState();
    final date = context.read<AttendanceProvider>().selectedDate;
    _loadAttendance(context, date);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final selectedDate = provider.selectedDate;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Class Attendance"),
      ),
      body: Column(
        children: [
          CalendarTimeline(
            initialDate: selectedDate,
            firstDate: DateTime(2021, 1, 1),
            lastDate: DateTime(2030, 12, 31),
            monthColor: Colors.blue.shade900,
            activeBackgroundDayColor: Colors.blue,
            onDateSelected: (date) {
              provider.setSelectedDate(date);
              _loadAttendance(context, date);
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    provider.markAllPresent(selectedDate);
                    _loadAttendance(context, selectedDate);
                  },
                  child: Text("Mark Attendance"),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.deleteAttendance(selectedDate);
                    _loadAttendance(context, selectedDate);
                  },
                  child: Icon(Icons.delete),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _attendanceList.isEmpty
                ? Center(
              child: Text(
                'No attendance marked for this date',
                style: TextStyle(color: Colors.white),
              ),
            )
                : ListView.builder(
              itemCount: _attendanceList.length,
              itemBuilder: (context, index) {
                final student = _attendanceList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentAttendancePage(student),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.grey[900],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                    shadowColor: Colors.white24,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Roll No: ${student.roll}',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                student.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              provider.toggleAttendance(student.name, selectedDate);
                              _loadAttendance(context, selectedDate);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              student.status == 'P' ? Colors.green : Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              student.status,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
