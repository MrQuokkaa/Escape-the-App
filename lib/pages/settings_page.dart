import '../exports/package_exports.dart';
import '../exports/theme_exports.dart';
import '../exports/page_exports.dart';
import '../exports/util_exports.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedTheme = 'Blue';

  @override
  void initState() {
    super.initState();
    selectedTheme = Provider.of<UserProvider>(context, listen: false).themeName;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;

    final sortedPresets = presets.toList()
      ..sort((a, b) => a.name == selectedTheme
          ? -1
          : b.name == selectedTheme
              ? 1
              : 0);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            "Settings",
            style: textTheme.headlineLarge,
          ),
        ),
        actions: [
          if (debugMode)
          Padding(
            padding: EdgeInsets.only(top:20, right: 10),
            child: IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DebugPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: InkWell(
              onTap: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;

                final doc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('defaultTodos')
                    .doc('Monday')
                    .get();

                List<List<dynamic>> tasks = [];
                if (doc.exists) {
                  final data = doc.data();
                  if (data != null && data['tasks'] is List) {
                    tasks = List<List<dynamic>>.from(
                      data['tasks']
                          .map((task) => [task['name'], task['completed']]),
                    );
                  }
                }

                await Future.delayed(const Duration(milliseconds: 50));

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DefaultTodoPage(weekday: 'Monday', toDoList: tasks),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "Edit Default Tasks",
                  style: textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("App Theme", style: textTheme.bodyLarge),
                DropdownButton<String>(
                  value: sortedPresets.any((p) => p.name == selectedTheme)
                      ? selectedTheme
                      : sortedPresets.first.name,
                  items: sortedPresets.map((preset) {
                    return DropdownMenuItem<String>(
                      value: preset.name,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: preset.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                          Text(preset.name, style: textTheme.bodyLarge),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    debugLog('[Settings] Dropdown changed to: $value');
                    if (value == null) return;
                    setState(() => selectedTheme = value);

                    final brightness = userProvider.brightness;
                    await userProvider.updateTheme(value,
                        brightness: brightness);
                    debugLog('[Settings] Theme updated and saved for user');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
