import '../exports/package_exports.dart';
import 'package:intl/intl.dart';

class FirestoreDataBase with ChangeNotifier {
  Map<String, List<List<dynamic>>> _tasksByDate = {};

  DateTime? _currentDay;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreDataBase();

  String get userId => _auth.currentUser!.uid;

  String getKeyForDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<List<dynamic>> getTasksForDate(DateTime date) {
    final key = getKeyForDate(date);
    return _tasksByDate[key] ?? [];
  }

  List<List<dynamic>> get todayTasks => getTasksForDate(DateTime.now());

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDataForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    String key = getKeyForDate(date);

    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(key)
        .get();

    List<List<dynamic>> tasksForDate;

    if (snapshot.exists &&
        snapshot.data() != null &&
        (snapshot.data()! as Map).containsKey('items')) {
      tasksForDate = (snapshot['items'] as List)
          .map((item) => [item['name'], item['completed']])
          .toList();
    } else {
      String weekday = DateFormat('EEEE').format(date);
      DocumentSnapshot defaultSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('defaultTodos')
          .doc(weekday)
          .get();

      if (defaultSnapshot.exists &&
          defaultSnapshot.data() != null &&
          (defaultSnapshot.data()! as Map).containsKey('tasks')) {
        tasksForDate = List<List<dynamic>>.from(
          (defaultSnapshot['tasks'] as List).map(
            (task) => [task['name'], task['completed']],
          ),
        );
      } else {
        tasksForDate = [];
      }
    }

    _tasksByDate[key] = tasksForDate;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDataForDate(DateTime date) async {
    String key = getKeyForDate(date);
    final tasks = _tasksByDate[key] ?? [];

    List<Map<String, dynamic>> mappedList = tasks
        .map((item) => {
              'name': item[0],
              'completed': item[1],
            })
        .toList();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(key)
        .set({'items': mappedList});
    notifyListeners();
  }

  Future<void> addTask(String taskName, DateTime date) async {
    final key = getKeyForDate(date);
    final tasks = _tasksByDate[key] ?? [];
    tasks.add([taskName, false]);
    _tasksByDate[key] = List.from(tasks);
    await updateDataForDate(date);
    notifyListeners();
  }

  Future<void> deleteTask(int index, DateTime date) async {
    final key = getKeyForDate(date);
    final tasks = _tasksByDate[key] ?? [];
    if (index >= 0 && index < tasks.length) {
      tasks.removeAt(index);
      _tasksByDate[key] = List.from(tasks);
      await updateDataForDate(date);
      notifyListeners();
    }
  }

  Future<void> completeTask(int index, DateTime date) async {
    final key = getKeyForDate(date);
    final tasks = _tasksByDate[key] ?? [];
    if (index >= 0 && index < tasks.length) {
      final updatedTasks = tasks
          .asMap()
          .entries
          .map((entry) => entry.key == index
              ? [entry.value[0], !(entry.value[1] as bool)]
              : [...entry.value])
          .toList();
      _tasksByDate[key] = updatedTasks;
      await updateDataForDate(date);
      await loadDataForDate(date);
    }
  }

  Future<void> updateToday(DateTime newDay) async {
    if (_currentDay == null || !_isSameDay(_currentDay!, newDay)) {
      _currentDay = newDay;
      await loadDataForDate(newDay);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
