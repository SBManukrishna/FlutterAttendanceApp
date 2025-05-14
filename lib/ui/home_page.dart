import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:student_attendance/providers/attendance_provider.dart';
import 'package:student_attendance/models/student_model.dart';
import 'package:student_attendance/ui/attendance_line_chart.dart';
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

  Map<DateTime, int> buildAttendanceDataFromHive() {
    final attendanceData = <DateTime, int>{};
    final historyBox = Hive.box<Map>('studentAttendanceHistory');

    // Iterate through all the students in historyBox
    for (final studentName in historyBox.keys) {
      final history = historyBox.get(studentName, defaultValue: {}) as Map;

      // Iterate through each date the student was marked as present or absent
      history.forEach((dateKey, status) {
        final date = DateTime.parse(dateKey);  // Convert string to DateTime
        if (status == 'P') {
          // If the status is "P", increment the present count for that date
          attendanceData.update(date, (count) => count + 1, ifAbsent: () => 1);
        }
      });
    }

    return attendanceData;
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
        title: const Text('Attendance Dashboard'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () {
              final attendanceData = buildAttendanceDataFromHive();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceStickChart(attendanceData: attendanceData),
                ),
              );
            },
          ),
        ],
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
                  child: Text("Mark Attendance",style: TextStyle(color: Colors.blue.shade100),),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.deleteAttendance(selectedDate);
                    _loadAttendance(context, selectedDate);
                  },
                  child: Icon(Icons.delete,color: Colors.blue.shade100,),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _attendanceList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Lottie.asset(
                    'assets/attendance_animation.json', // Path to your JSON animation file
                    width: 250,  // Adjust the size as needed
                    height: 250,
                    fit: BoxFit.fill,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 200.0),
                    child: Text("No attendance !",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                  )
                ],
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
