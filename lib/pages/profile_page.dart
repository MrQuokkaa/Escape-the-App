import '../exports/package_exports.dart';
import '../exports/page_exports.dart';
import '../exports/util_exports.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Functions f = Functions();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final userProvider = Provider.of<UserProvider>(context);

    final userName = userProvider.cachedDisplayName;

    final int level = userProvider.level;

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
            'Profile',
            style: textTheme.headlineLarge,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 10),
              child: IconButton(
                icon: Icon(Icons.logout),
                onPressed: () => f.logout(context),
              ),
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            userName,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Level $level',
                            style: textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        // Background
                                        Container(
                                          height: 14,
                                          color: Colors.grey.shade300,
                                        ),
                                        //FractionallySizedBox(
                                        //  alignment: Alignment.centerLeft,
                                        //  widthFactor: progress,
                                        //  child: Container(
                                        //    height: 14,
                                        //    color: Theme.of(context)
                                        //        .colorScheme
                                        //        .primary,
                                        //  ),
                                        //),
                                        Positioned.fill(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              int tickCount = 3;
                                              double spacing =
                                                  constraints.maxWidth /
                                                      (tickCount + 1);

                                              return Stack(
                                                children: List.generate(
                                                    tickCount, (index) {
                                                  return Positioned(
                                                    left:
                                                        spacing * (index + 1) -
                                                            1,
                                                    top: 2,
                                                    bottom: 2,
                                                    child: Container(
                                                      width: 2,
                                                      color: Colors.white
                                                          .withValues(alpha: 0.7),
                                                    ),
                                                  );
                                                }),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                        ]))
                  ],
                ),
                const SizedBox(height: 32),
                const Center(child: Text("Profile Page Context Placeholder"))
              ],
            )));
  }
}
