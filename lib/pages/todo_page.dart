import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../exports/package_exports.dart';
import '../exports/theme_exports.dart';
import '../exports/data_exports.dart';
import '../exports/util_exports.dart';

class ToDoPage extends StatefulWidget {
  final DateTime selectedDate;
  const ToDoPage({super.key, required this.selectedDate});

  @override
  State<ToDoPage> createState() => _ToDoState();
}

class _ToDoState extends State<ToDoPage> {
  late final FirestoreDataBase db;

  final Functions f = Functions();
  final _controller = TextEditingController();

  late DateTime selectedDate;
  late DayWatcher _dayWatcher;

  @override
  void initState() {
    super.initState();
    db = Provider.of<FirestoreDataBase>(context, listen: false);

    selectedDate = widget.selectedDate;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await db.loadDataForDate(selectedDate);
      setState(() {});
    });

    _dayWatcher = DayWatcher(
      onDayChanged: (newLogicalDay) async {
        selectedDate = newLogicalDay;
        await db.loadDataForDate(selectedDate);
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    db.updateDataForDate(selectedDate);
    _controller.dispose();
    _dayWatcher.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      await db.loadDataForDate(selectedDate);
      setState(() {});
    }
  }

  String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) return "Today";
    if (selected == tomorrow) return "Tomorrow";
    return DateFormat('EEE, d MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Consumer<FirestoreDataBase>(
      builder: (context, db, _) {
        final tasks = db.getTasksForDate(selectedDate);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: GestureDetector(
              onTap: _pickDate,
              child: Text("Tasks for ${getFormattedDate(selectedDate)}",
                  style: textTheme.headlineMedium),
            ),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => DialogBox(
                  controller: _controller,
                  onSave: () async {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    await db.addTask(text, selectedDate);
                    _controller.clear();
                    Navigator.of(context).pop();
                  },
                  onCancel: () => Navigator.of(context).pop(),
                ),
              );
            },
            backgroundColor: themeColor(context).primary,
            child: Icon(Icons.add),
          ),
          body: SlidableAutoCloseBehavior(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ToDoTile(
                  taskName: tasks[index][0],
                  taskCompleted: tasks[index][1],
                  onChanged: (_) async {
                    await db.completeTask(index, selectedDate);
                  },
                  deleteFunction: (_) async {
                    await db.deleteTask(index, selectedDate);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
