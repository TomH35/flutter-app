import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'todo_provider.dart';

/// Hlavná stránka aplikácie so zoznamom úloh (To-Do list).
/// Všetky dáta a logika sú v TodoProvider.
class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  /// Hlavné rozloženie obrazovky
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Umiestnenie tlačidla v strede dole
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // Tlačidlo na pridanie úlohy
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoSheet(context),
        child: const Icon(Icons.add),
      ),

      // Horný AppBar s názvom
      appBar: AppBar(title: const Text('My Todos')),

      // Obsah obrazovky – buď text, alebo zoznam úloh
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) => provider.isEmpty
            ? const Center(child: Text('Nothing to do!'))
            : ListView.builder(
                itemCount: provider.todos.length,
                itemBuilder: (context, index) {
                  final todo = provider.todos[index];
                  return TodoItem(
                    key: ValueKey(todo.id),
                    todo: todo,
                    onChanged: (value) =>
                        provider.toggleTodoStatus(index, value),
                    onDelete: () => provider.removeTodo(index),
                  );
                },
              ),
      ),
    );
  }

  /// Zobrazí spodné okno (BottomSheet) na pridanie novej úlohy
  void _showAddTodoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddTodoSheet(),
    );
  }
}

/// Obsah spodného okna – textové pole, výber priority a tlačidlo SAVE.
/// StatefulWidget je tu len kvôli správnemu uvoľneniu TextEditingControllera.
class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  // Kontrolér na prístup k hodnote z TextFieldu
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Funkcia, ktorá sa zavolá pri kliknutí na "SAVE"
  void _addTodo() {
    final provider = Provider.of<TodoProvider>(context, listen: false);

    if (!provider.addTodo(_controller.text)) {
      showMsg(context, 'Input field must not be empty');
      return;
    }

    // Zatvorenie spodného okna (BottomSheet)
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        // Okno sa posunie nad klávesnicu
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Textové pole pre názov úlohy
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'What to do?'),
          ),

          // Nadpis "Select Priority"
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Select Priority'),
          ),

          // Tri rádiové tlačidlá – výber priority (stav je v TodoProvider)
          Consumer<TodoProvider>(
            builder: (context, provider, child) => RadioGroup<TodoPriority>(
              groupValue: provider.priority,
              onChanged: (value) => provider.setPriority(value!),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final priority in TodoPriority.values) ...[
                    Radio<TodoPriority>(value: priority),
                    Text(priority.label),
                  ],
                ],
              ),
            ),
          ),

          // Tlačidlo na uloženie úlohy
          ElevatedButton(onPressed: _addTodo, child: const Text('SAVE')),
        ],
      ),
    );
  }
}

/// Pomocná funkcia – zobrazí dialógové okno s chybovou hláškou
void showMsg(BuildContext context, String s) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Caution!'),
      content: Text(s),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
      ],
    ),
  );
}

/// Farba podľa priority úlohy
Color priorityColor(TodoPriority priority) {
  switch (priority) {
    case TodoPriority.low:
      return Colors.green;
    case TodoPriority.normal:
      return Colors.orange;
    case TodoPriority.high:
      return Colors.red;
  }
}

/// Widget pre jednotlivú úlohu – riadok so zaškrtávacím políčkom
/// a tlačidlom na odstránenie
class TodoItem extends StatelessWidget {
  final MyTodo todo;
  final Function(bool) onChanged;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(todo.priority);

    return Container(
      // Farebný pruh vľavo podľa priority
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 6)),
      ),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          todo.name,
          style: TextStyle(
            decoration: todo.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          'Priority: ${todo.priority.label}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        value: todo.completed,
        onChanged: (value) {
          onChanged(value!);
        },
        secondary: IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
