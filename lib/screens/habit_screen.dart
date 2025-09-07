import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() {
    return _HabitScreenState();
  }
}

class _HabitScreenState extends State<HabitScreen> {
  DateTime _selectedDate = DateTime.now();

  List<DateTime> get _past7Days => List.generate(
    7,
    (index) => DateTime.now().subtract(Duration(days: 6 - index)),
  );

  final List<String> _habits = [];
  final Map<String, Map<String, bool>> _habitCompletion = {};

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  void _addHabit(String title) {
    setState(() {
      _habits.add(title);
      _habitCompletion[title] = {};
    });
  }

  void _openAddHabitDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'New Habit',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          content: TextField(
            controller: controller,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
            decoration: const InputDecoration(hintText: 'Enter Habit Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  _addHabit(text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: _past7Days.length,
              itemBuilder: (ctx, index) {
                final day = _past7Days[index];
                final isSelected =
                    _selectedDate.day == day.day &&
                    _selectedDate.month == day.month &&
                    _selectedDate.year == day.year;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orangeAccent : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('EEE, d').format(day),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[100],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: _habits.isEmpty
                ? Center(
                    child: Text(
                      'No habits yet. Tap + to add one!',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      final habit = _habits[index];
                      final dateKey = _dateKey(_selectedDate);
                      final isDone = _habitCompletion[habit]?[dateKey] ?? false;
                      return Dismissible(
                        key: Key(habit),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          final removedHabit = habit;
                          final removedCompletion = _habitCompletion[habit];
                          setState(() {
                            _habits.removeAt(index);
                            _habitCompletion.remove(habit);
                          });
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$habit deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  setState(() {
                                    _habits.insert(index, removedHabit);
                                    _habitCompletion[removedHabit] =
                                        removedCompletion ?? {};
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          color: const Color.fromARGB(255, 175, 15, 4),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(
                            habit,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          trailing: Checkbox(
                            value: isDone,
                            onChanged: (val) {
                              setState(() {
                                _habitCompletion[habit]?[dateKey] =
                                    val ?? false;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddHabitDialog,
        child: const Icon(Icons.add, size: 25),
      ),
    );
  }
}
