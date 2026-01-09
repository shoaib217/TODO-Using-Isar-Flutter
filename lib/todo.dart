import 'package:isar/isar.dart';

part 'todo.g.dart';


@collection
class Todo {
  // In v4, use a plain int or Id.
  // To auto-increment, you leave it unassigned or set it to a specific value during 'put'.
  Id id = Isar.autoIncrement; // you can also use id = null to auto increment

  late String title;

  bool isDone = false;

  String? category; // e.g., Work, Personal

  DateTime createdAt = DateTime.now();

  int priority = 1;

}
