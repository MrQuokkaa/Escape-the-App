import '../../exports/package_exports.dart';
import '../../exports/util_exports.dart';
import '../../exports/page_exports.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Functions f = Functions();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  /// Convert username into a fake email so FirebaseAuth accepts it
  String _usernameToEmail(String username) {
    return '${username.trim().toLowerCase()}@app.local';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Team naam',
                labelStyle: textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Wachtwoord',
                labelStyle: textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () async {
                try {
                  final email = _usernameToEmail(_usernameController.text);
                  final user = await f.login(
                    email,
                    _passwordController.text.trim(),
                  );
                  if (user != null && context.mounted) {
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    await userProvider.loadUserData();
                    debugLog('[Login] Theme loaded..');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(),
                      ),
                    );
                    debugLog('[Login] User is being logged in..');
                  }
                } catch (e) {
                  setState(() => _error = e.toString());
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}