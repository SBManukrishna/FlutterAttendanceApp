import 'package:hive/hive.dart';

part 'student_model.g.dart'; // Needed for Hive code generation

@HiveType(typeId: 0)
class Student extends HiveObject {
  @HiveField(0)
  final int roll;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String status; // 'P' or 'A'

  Student({required this.roll, required this.name, required this.status});
}
