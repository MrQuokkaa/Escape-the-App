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
  String? selectedUserId;
  int? newLevel;
  int? currentLevel;

  final TextEditingController _levelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedTheme = Provider.of<UserProvider>(context, listen: false).themeName;
  }

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final textTheme = Theme.of(context).textTheme;
    final firestore = FirebaseFirestore.instance;

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
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            "Settings",
            style: textTheme.headlineLarge,
          ),
        ),
        actions: [
          if (debugMode)
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 10),
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
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Register New Account'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Leaderboard'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatusPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text("Manage User Levels", style: textTheme.headlineSmall),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['dev'] != true; // exclude devs
                }).toList();

                if (users.isEmpty) {
                  return const Text("No users found.");
                }

                return DropdownButton<String>(
                  value: selectedUserId,
                  hint: const Text("Select a user"),
                  items: users.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['displayName'] ?? 'Unknown';
                    final level = data['level'] ?? 0;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text("$name (Level $level)"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedUserId = value;
                      final userDoc = users.firstWhere((doc) => doc.id == value);
                      final data = userDoc.data() as Map<String, dynamic>;
                      currentLevel = data['level'] ?? 0;
                      newLevel = currentLevel;
                      _levelController.text = currentLevel.toString();
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          if (selectedUserId != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _levelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "New Level",
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  setState(() => newLevel = int.tryParse(val));
                },
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: newLevel == null
                    ? null
                    : () async {
                        await firestore
                            .collection('users')
                            .doc(selectedUserId)
                            .set({'level': newLevel},
                                SetOptions(merge: true));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Level updated!")),
                        );
                      },
                child: const Text("Update Level"),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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