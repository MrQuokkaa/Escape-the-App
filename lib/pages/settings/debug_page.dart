import '../../exports/package_exports.dart';
import '../../exports/theme_exports.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final TextEditingController _xpController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Debug Page", style: textTheme.headlineLarge),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildColorPreview(context, "Primary", themeColor(context).primary),
          const Divider(),
          _buildColorPreview(
              context, "Secondary", themeColor(context).secondary),
          const Divider(),
          _buildColorPreview(context, "Tertiary", themeColor(context).tertiary),
          const Divider(height: 32),
          Text("Manual XP / Level Input", style: textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _xpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "XP",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final int? xpToAdd = int.tryParse(_xpController.text);
              if (xpToAdd != null) {
                userProvider.addXP(xpToAdd);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Added $xpToAdd XP")),
                );
              }
            },
            child: const Text("Add XP"),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final int? newXP = int.tryParse(_xpController.text);
              if (newXP != null) {
                userProvider.updateXP(newXP);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("XP set to $newXP")),
                );
              }
            },
            child: const Text("Set Exact XP"),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _levelController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Level",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final int? newLevel = int.tryParse(_levelController.text);
              if (newLevel != null) {
                userProvider.updateLevel(newLevel);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Level updated to $newLevel")),
                );
              }
            },
            child: const Text("Update Level"),
          )
        ],
      ),
    );
  }

  Widget _buildColorPreview(BuildContext context, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 50,
        color: color,
        child: Center(
          child: Text('Current $label Color'),
        ),
      ),
    );
  }
}
