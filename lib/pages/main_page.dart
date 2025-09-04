import '../exports/package_exports.dart';
import '../exports/page_exports.dart';
import '../exports/util_exports.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Functions f = Functions();

  late List<Widget> pages;
  late int currentPage;

  @override
  void initState() {
    super.initState();
    pages = [
      const HomePage(),
      const ProfilePage(),
      const SettingsPage(),
    ];

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    currentPage = userProvider.isDev ? 2 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        width: 200,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Level selectie',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                setState(() => currentPage = 0);
                Navigator.pop(context); // close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profiel'),
              onTap: () {
                setState(() => currentPage = 1);
                Navigator.pop(context);
              },
            ),
            if (userProvider.isDev)
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  setState(() {
                    if (pages.length < 3) pages.add(const SettingsPage());
                    currentPage = 2;
                  });
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: pages[currentPage],
    );
  }
}
