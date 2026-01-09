import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'todo.dart';

class IsarService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([TodoSchema], directory: dir.path);
  }

  // Create
  Future<void> addTodo(String title, String category, int priority) async {
    final newTodo = Todo()
      ..title = title
      ..category = category
      ..priority = priority
      ..createdAt = DateTime.now();

    await isar.writeTxn(() => isar.todos.put(newTodo));
  }

  // Update
  Future<void> updateTodo(Todo todo) async {
    await isar.writeTxn(() => isar.todos.put(todo));
  }

  // Toggle Done
  Future<void> toggleTodo(Todo todo) async {
    todo.isDone = !todo.isDone;
    await isar.writeTxn(() => isar.todos.put(todo));
  }

  // Delete
  Future<void> deleteTodo(Id id) async {
    await isar.writeTxn(() => isar.todos.delete(id));
  }

  // Watch (Sorted by newest first)
  Stream<List<Todo>> watchTodos() {
    return isar.todos.where().sortByPriorityDesc().thenByCreatedAtDesc().watch(fireImmediately: true);
  }
}
