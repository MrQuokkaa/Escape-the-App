import '../exports/package_exports.dart';
import '../exports/util_exports.dart';
import '../exports/data_exports.dart';
import '../exports/page_exports.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final userProvider = UserProvider();

  runApp(MyApp(
    userProvider: userProvider,
  ));
}

class MyApp extends StatelessWidget {
  final UserProvider userProvider;

  const MyApp({
    super.key,
    required this.userProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider(create: (_) => FirestoreDataBase()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, theme, _) {
          final user = FirebaseAuth.instance.currentUser;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme.themeData,
            initialRoute: '/',
            routes: {
              '/': (context) =>
                  user != null ? const AutoLogin() : const LoginPage(),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/settings': (context) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}

class AutoLogin extends StatefulWidget {
  const AutoLogin({super.key});

  @override
  State<AutoLogin> createState() => _AutoLoginState();
}

class _AutoLoginState extends State<AutoLogin> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    while (!userProvider.hasLoadedData) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    final imageUrl = userProvider.imageUrl;
    if (imageUrl.isNotEmpty) {
      await precacheImage(CachedNetworkImageProvider(imageUrl), context);
    } else {
      await precacheImage(const AssetImage('assets/images/default_avatar.png'), context);         debugLog('[Login] Default avatar cached..');
    }

    debugLog('[AutoLogin] Profile image cached..');
    setState(() => _isReady = true);
  }
  
  @override
  Widget build(BuildContext context) {
    return _isReady
      ? MainPage()
      : const Scaffold(body: SizedBox.shrink());
  }
}
