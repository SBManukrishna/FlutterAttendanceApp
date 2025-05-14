import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceStickChart extends StatefulWidget {
  final Map<DateTime, int> attendanceData;

  const AttendanceStickChart({required this.attendanceData, super.key});

  @override
  _AttendanceStickChartState createState() => _AttendanceStickChartState();
}

class _AttendanceStickChartState extends State<AttendanceStickChart> {
  Map<DateTime, int> filteredAttendanceData = {};
  DateTimeRange? customRange;

  @override
  void initState() {
    super.initState();
    filteredAttendanceData = widget.attendanceData; // Initially show all data
  }

  // Filter based on selection
  void _filterData(String filterOption) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday of this week
    final startOfMonth = DateTime(now.year, now.month, 1); // First day of this month

    setState(() {
      switch (filterOption) {
        case 'This Week':
          filteredAttendanceData = Map.fromEntries(
            widget.attendanceData.entries.where((entry) => entry.key.isAfter(startOfWeek.subtract(Duration(days: 1)))),
          );
          break;
        case 'This Month':
          filteredAttendanceData = Map.fromEntries(
            widget.attendanceData.entries.where((entry) => entry.key.isAfter(startOfMonth.subtract(Duration(days: 1)))),
          );
          break;
        case 'Custom Range':
        // Handle custom range logic here
          if (customRange != null) {
            filteredAttendanceData = Map.fromEntries(
              widget.attendanceData.entries.where((entry) =>
              entry.key.isAfter(customRange!.start.subtract(Duration(days: 1))) &&
                  entry.key.isBefore(customRange!.end.add(Duration(days: 1)))),
            );
          }
          break;
        default:
          filteredAttendanceData = widget.attendanceData; // Show all data
          break;
      }
    });
  }

  // Handle custom range date picker
  void _pickCustomRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        customRange = picked;
        _filterData('Custom Range');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort the dates to maintain chronological order
    final sortedDates = filteredAttendanceData.keys.toList()..sort();
    final dateLabels = sortedDates.map((d) => DateFormat('MMM d').format(d)).toList();

    // Prepare the data for plotting the "sticks"
    final spots = List.generate(
      sortedDates.length,
          (i) => FlSpot(
        i.toDouble(),
        filteredAttendanceData[sortedDates[i]]!.toDouble(),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Attendance Overview'),
        backgroundColor: Colors.black,
        actions: [
          PopupMenuButton<String>(
            onSelected: (filterOption) {
              if (filterOption == 'Custom Range') {
                _pickCustomRange(context);
              } else {
                _filterData(filterOption);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'This Week', child: Text('This Week')),
              const PopupMenuItem(value: 'This Month', child: Text('This Month')),
              const PopupMenuItem(value: 'Custom Range', child: Text('Custom Range')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,  // Makes the chart use vertical sticks
                      color: Colors.lightBlueAccent,
                      belowBarData: BarAreaData(show: false),  // No filled area under the line
                      barWidth: 5,  // Width of the sticks
                      dotData: FlDotData(show: false),  // No dots on data points
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value.toInt() >= 0 && value.toInt() < dateLabels.length) {
                            return Transform.translate(
                              offset: const Offset(-10, 5),
                              child: Text(
                                dateLabels[value.toInt()],
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                        interval: 1,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          // Display whole number on Y-axis
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          );
                        },
                        reservedSize: 35,
                        interval: 1,
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 50),
            Text(
              'Total Working Days: ${filteredAttendanceData.length}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
