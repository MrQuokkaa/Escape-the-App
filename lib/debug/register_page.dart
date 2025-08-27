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
    final userProvider = Provider.of<UserProvider>(context);
    
    // Only devs can access this page
    if (!userProvider.isDev) {
      return Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: const Center(
          child: Text(
            'Registration is only available for developers.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

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
                  await f.register(name, email, password);

                  if (context.mounted) {
                    debugLog('[Register] Account created, dev remains logged in.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('New account created successfully.')),
                    );

                    _nameController.clear();
                    _emailController.clear();
                    _passwordController.clear();
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