import '../exports/package_exports.dart';
import '../exports/util_exports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Functions f = Functions();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              f.getGreeting(userName),
              style: textTheme.headlineLarge,
            ),
            Text(
              "Veel succes!",
              style: textTheme.titleMedium,
            ),
          ],
        ),
      ),
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Enter something',
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    ),
    );
  }
}
