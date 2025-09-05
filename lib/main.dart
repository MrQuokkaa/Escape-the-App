import '../exports/package_exports.dart';
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
      ],
      child: Consumer<UserProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme.themeData,
            initialRoute: '/',
            routes: {
              '/': (context) => const StartPage(),
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