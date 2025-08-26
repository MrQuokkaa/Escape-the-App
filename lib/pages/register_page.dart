import '../exports/package_exports.dart';
import '../exports/util_exports.dart';
import '../exports/page_exports.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final Functions f = Functions();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Create a new account", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();

                if (name.isEmpty) {
                  setState(() => _error = 'Please enter your name.');
                  return;
                }

                try {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  
                  final user = await f.register(name, email, password);

                  debugLog('[Register] Checking created user data..');
                  userProvider.clearProfile();
                  userProvider.loadUserData();

                  if (user != null && context.mounted) {
                    debugLog('[Register] Navigating to app..');              
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(),
                      ),
                    );
                  }
                } catch (e) {
                  setState(() => _error = e.toString());
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
