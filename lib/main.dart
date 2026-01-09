import 'package:flutter/material.dart';
import 'todo.dart';
import 'isar_service.dart';

void main() async {  WidgetsFlutterBinding.ensureInitialized();
await IsarService.init();
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final service = IsarService();
  final TextEditingController _controller = TextEditingController();

  // Key for the AnimatedList
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  // Local list to track state changes for animations
  List<Todo> _lastData = [];

  String _tempCategory = 'Work';
  int _tempPriority = 1;



  void _showTodoSheet({Todo? todo}) {
    if (todo != null) {
      _controller.text = todo.title;
      _tempCategory = todo.category ?? 'Work';_tempPriority = todo.priority;
    } else {
      _controller.clear();
      _tempCategory = 'Work';
      _tempPriority = 1;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, double value, child) {
            return Opacity(
              // FIX: Clamp the value so it never goes below 0.0 or above 1.0
              opacity: value.clamp(0.0, 1.0),
              child: Transform.translate(
                // The Transform can still use the 'overshoot' for the bounce effect
                offset: Offset(0, 50 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 25, right: 25, top: 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  todo == null ? 'New Task' : 'Edit Task',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'What needs to be done?',
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text("Category", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: ['Work', 'Personal', 'Shopping'].map((cat) {
                    return ChoiceChip(
                      label: Text(cat),
                      selected: _tempCategory == cat,
                      onSelected: (val) => setModalState(() => _tempCategory = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text("Priority", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _prioChip(setModalState, 0, "Low", Colors.green),
                    _prioChip(setModalState, 1, "Med", Colors.orange),
                    _prioChip(setModalState, 2, "High", Colors.red),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      if (todo == null) {
                        service.addTodo(_controller.text, _tempCategory, _tempPriority);
                      } else {
                        todo.title = _controller.text;
                        todo.category = _tempCategory;
                        todo.priority = _tempPriority;
                        service.updateTodo(todo);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(todo == null ? 'Create Task' : 'Update Task'),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _prioChip(StateSetter setState, int val, String label, Color color) {
    bool isSelected = _tempPriority == val;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: color.withOpacity(0.2),
        onSelected: (selected) => setState(() => _tempPriority = val),
      ),
    );
  }

  // Helper widget to build the individual items with animation
  Widget _buildItem(Todo todo, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            leading: Checkbox(
              value: todo.isDone,
              onChanged: (v) => service.toggleTodo(todo),
            ),
            title: Text(todo.title,
                style: TextStyle(decoration: todo.isDone ? TextDecoration.lineThrough : null)),
            subtitle: Text("${todo.category} • ${['Low', 'Medium', 'High'][todo.priority]} Priority"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _showTodoSheet(todo: todo)),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => _handleDelete(todo, index)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Animation logic for deletion
  void _handleDelete(Todo todo, int index) {
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => _buildItem(todo, animation, index),
      duration: const Duration(milliseconds: 300),
    );
    service.deleteTodo(todo.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Isar Task Manager')),
      body: StreamBuilder<List<Todo>>(
        stream: service.watchTodos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final currentData = snapshot.data!;

          // Detect additions to trigger the entry animation
          if (currentData.length > _lastData.length) {
            final int newItemsCount = currentData.length - _lastData.length;
            for (int i = 0; i < newItemsCount; i++) {
              _listKey.currentState?.insertItem(i, duration: const Duration(milliseconds: 400));
            }
          }

          _lastData = List.from(currentData);

          if (currentData.isEmpty) {
            return const Center(child: Text("No tasks yet."));
          }

          return AnimatedList(
            key: _listKey,
            initialItemCount: currentData.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index, animation) {
              // Ensure we don't go out of bounds during quick deletions
              if (index >= currentData.length) return const SizedBox.shrink();
              return _buildItem(currentData[index], animation, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTodoSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
