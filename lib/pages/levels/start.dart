import '../../exports/package_exports.dart';
import '../../exports/page_exports.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor:  Color(0xFFFFFDFA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welkom!", style: textTheme.headlineMedium),
              Text("Zijn jullie klaar?", style: textTheme.bodyMedium),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      )
    );
  }
}