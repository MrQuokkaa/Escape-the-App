import '../exports/package_exports.dart';
import '../exports/util_exports.dart';
import '../exports/page_exports.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Functions f = Functions();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: textTheme.headlineLarge),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome back!", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
                labelStyle: textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                labelStyle: textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = await f.login(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                  if (user != null && context.mounted) {
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    await userProvider.loadUserData();
                    debugLog('[Login] Theme loaded..');

                    final imageUrl = userProvider.imageUrl;
                    if (imageUrl.isNotEmpty) {
                      await precacheImage(
                          CachedNetworkImageProvider(imageUrl), context);
                      debugLog('[Login] Profile image cached..');
                    } else {
                      await precacheImage(
                          const AssetImage('assets/images/default_avatar.png'),
                          context);
                      debugLog('[Login] Default avatar cached..');
                    }

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
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
