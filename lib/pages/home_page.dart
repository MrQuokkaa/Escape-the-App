import '../exports/package_exports.dart';
import '../exports/theme_exports.dart';
import '../exports/page_exports.dart';
import '../exports/util_exports.dart';
import '../exports/data_exports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static void resetCard() {
    _HomePageState._cardVisible = false;
    debugLog('[Logout] Unloaded card');
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Functions f = Functions();
  DateTime get logicalToday => _dayWatcher.getLogicalDate(DateTime.now());
  late DayWatcher _dayWatcher;

  int taskCount = 0;
  bool isLoading = true;
  static bool _cardVisible = false;

  @override
  void initState() {
    super.initState();

    final db = Provider.of<FirestoreDataBase>(context, listen: false);

    _dayWatcher = DayWatcher(
      onDayChanged: (newDay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          db.updateToday(newDay);
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final db = Provider.of<FirestoreDataBase>(context, listen: false);

      await db.updateToday(logicalToday);
      await db.loadDataForDate(logicalToday);

      if (!mounted) return;

      Future.delayed(Duration.zero, () {
        if (!_cardVisible) {
          setState(() {
            _cardVisible = true;
          });
          debugLog('[Home] Card loaded, fading in..');
        } else {
          debugLog('[Home] Card is visible');
        }
      });
    });
  }

  @override
  void dispose() {
    _dayWatcher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final db = Provider.of<FirestoreDataBase>(context, listen: false);
    final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';

    final List<List<dynamic>> tasks = db.getTasksForDate(logicalToday);
    final int uncompletedCount = tasks.where((task) => task[1] == false).length;

    final Icon leadingIcon = Icon(
      uncompletedCount > 0 ? Icons.pending_actions : Icons.celebration,
      color: themeColor(context).tertiary,
    );

    final String titleText = uncompletedCount > 0
        ? "Uncompleted Tasks"
        : "You've finished all tasks 🎉";

    final Widget? subtitleText = uncompletedCount > 0
        ? Text(
            "$uncompletedCount task${uncompletedCount == 1 ? '' : 's'} remaining",
            style: TextStyle(fontSize: 16),
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            f.appBarText(context),
            Text(
              f.getGreeting(userName),
              style: textTheme.titleMedium,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: _cardVisible ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: !_cardVisible
                  ? const SizedBox(height: 70)
                  : GestureDetector(
                      onTap: () async {
                        final db = Provider.of<FirestoreDataBase>(context,
                            listen: false);
                        final logicalToday =
                            _dayWatcher.getLogicalDate(DateTime.now());

                        await db.loadDataForDate(logicalToday);
                        debugLog('[Home] Task-list was empty, loaded data');

                        if (!mounted) return;
                        debugLog('[Home] Redirecting to ToDo Page..');

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ToDoPage(selectedDate: logicalToday),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: themeColor(context).primary,
                        child: ListTile(
                          leading: leadingIcon,
                          title: Text(
                            titleText,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: subtitleText,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            const Center(child: Text("Home Page Content Placeholder")),
          ],
        ),
      ),
    );
  }
}
