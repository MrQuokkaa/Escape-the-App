import '../../exports/package_exports.dart';
import '../../exports/theme_exports.dart';

class DefaultTodoPage extends StatefulWidget {
  final String weekday;
  final List<List<dynamic>> toDoList;

  const DefaultTodoPage(
      {required this.weekday, required this.toDoList, super.key});

  @override
  State<DefaultTodoPage> createState() => _DefaultTodoPageState();
}

class _DefaultTodoPageState extends State<DefaultTodoPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<List<dynamic>> toDoList = [];

  @override
  void initState() {
    super.initState();
    toDoList = widget.toDoList;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final tasks = toDoList
        .map((task) => {
              'name': task[0],
              'completed': task[1],
            })
        .toList();

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('defaultTodos')
        .doc(widget.weekday)
        .set({'tasks': tasks});
  }
  
  final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
  final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _save();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final day = days[index];
              final weekday = weekdays[index];
              final isSelected = weekday == widget.weekday;

              return GestureDetector(
                onTap: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;

                  final doc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('defaultTodos')
                    .doc(weekday)
                    .get();

                  List<List<dynamic>> tasks = [];
                  if (doc.exists) {
                    final data = doc.data();
                    if (data != null && data['tasks'] is List) {
                      tasks = List<List<dynamic>>.from(
                        data['tasks'].map((task) => [task['name'], task['completed']]),
                      );
                    }
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DefaultTodoPage(weekday: weekday, toDoList: tasks),
                    )
                  );
                  
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor(context).primary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    day,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              );
            }),
          ),
          Expanded(
            child: ReorderableListView(
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) async {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = toDoList.removeAt(oldIndex);
                  toDoList.insert(newIndex, item);
                });
                await _save();
                if (mounted) setState(() {});
              },
              children: toDoList.asMap().entries.map((entry) {
                int index = entry.key;
                var task = entry.value;
                return Card(
                  key: ValueKey(task[0]),
                  elevation: 2,
                  color: themeColor(context).primary,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: index,
                          child: Icon(Icons.drag_handle,
                              color: themeColor(context).tertiary),
                        ),
                        SizedBox(width: 12),
                        Checkbox(
                          activeColor: themeColor(context).tertiary,
                          value: task[1],
                          onChanged: (_) async {
                            setState(() {
                              toDoList[index][1] = !toDoList[index][1];
                            });
                            await _save();
                            if (mounted) setState(() {});
                            ;
                          },
                        ),
                        Expanded(
                          child: Text(
                            task[0],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () async {
                            setState(() {
                              toDoList.removeAt(index);
                            });
                            await _save();
                            if (mounted) setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "New Task",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor(context).primary,
                  ),
                  onPressed: () async {
                    if (_controller.text.trim().isEmpty) return;
                    setState(() {
                      toDoList.add([_controller.text.trim(), false]);
                      _controller.clear();
                    });
                    await _save();
                    if (mounted) setState(() {});
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
