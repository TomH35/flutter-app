import 'package:flutter/foundation.dart';

/// Centrálny stav aplikácie – zoznam úloh a zvolená priorita novej úlohy
class TodoProvider extends ChangeNotifier {
  final List<MyTodo> _todos = [];

  // Predvolená priorita novej úlohy
  TodoPriority _priority = TodoPriority.normal;

  List<MyTodo> get todos => List.unmodifiable(_todos);

  TodoPriority get priority => _priority;

  bool get isEmpty => _todos.isEmpty;

  void setPriority(TodoPriority priority) {
    _priority = priority;
    notifyListeners();
  }

  /// Pridá novú úlohu so zvolenou prioritou.
  /// Vráti false, ak je názov prázdny.
  bool addTodo(String name) {
    if (name.trim().isEmpty) return false;

    _todos.add(
      MyTodo(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name.trim(),
        priority: _priority,
      ),
    );
    notifyListeners();
    return true;
  }

  /// Zmena stavu úlohy (označenie ako splnená / nesplnená)
  void toggleTodoStatus(int index, bool value) {
    _todos[index].completed = value;
    notifyListeners();
  }

  void removeTodo(int index) {
    _todos.removeAt(index);
    notifyListeners();
  }
}

/// Model (dátová trieda) pre jednu úlohu
class MyTodo {
  int id; // unikátne ID úlohy
  String name; // názov úlohy
  bool completed; // či je úloha dokončená
  TodoPriority priority; // priorita úlohy

  MyTodo({
    required this.id,
    required this.name,
    this.completed = false,
    required this.priority,
  });
}

/// Enum (výčtový typ) – tri úrovne priority
enum TodoPriority {
  low('Low'),
  normal('Normal'),
  high('High');

  const TodoPriority(this.label);

  final String label;
}
