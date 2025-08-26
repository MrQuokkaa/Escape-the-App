import '../exports/package_exports.dart';
import '../exports/widgets_exports.dart';
import '../exports/page_exports.dart';
import '../exports/util_exports.dart';
import 'dart:ui';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Functions f = Functions();
  String? _uploadError;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      try {
        debugLog('[Profile] Uploading profile picture');
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child('${user.uid}.jpg');

        await storageRef.putFile(file);
        debugLog('[Profile] Upload complete');
        final downloadUrl = await storageRef.getDownloadURL();
        debugLog('[Profile] Retrieved download URL: $downloadUrl');

        final fileInfo =
            await DefaultCacheManager().getFileFromCache(downloadUrl);
        if (fileInfo != null) {
          await DefaultCacheManager().removeFile(downloadUrl);
          debugLog('[Profile] Cached image removed');
        } else {
          debugLog('[Profile] No cached image found to remove');
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'profileImageUrl': downloadUrl}, SetOptions(merge: true));
        debugLog('[Profile] Firestore updated with new image URL');

        setState(() {
          _uploadError = null;
        });

        Provider.of<UserProvider>(context, listen: false)
            .updateProfile(imageUrl: downloadUrl);
        debugLog('[Profile] Provider updated with new image');
      } catch (e) {
        debugLog('[Profile] Image upload error: $e');
        setState(() {
          _uploadError = 'Failed to upload image. Please try again.';
        });
      }
    } else {
      debugLog('[Profile] No image was selected');
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0),
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UserAvatar(
                          imageUrl: imageUrl,
                          radius: 80,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            await _pickAndUploadImage();
                            setStateDialog(() {});
                          },
                          child: const Text("Change profile picture"),
                        ),
                        if (_uploadError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _uploadError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final userProvider = Provider.of<UserProvider>(context);

    final imageUrl = userProvider.imageUrl;
    final userName = userProvider.cachedDisplayName;

    final int level = userProvider.level;
    final int xp = userProvider.xp;

    final int neededXP = userProvider.neededXP;
    final bool hasLeveledUp = userProvider.hasLeveledUp;
    final double progress = userProvider.xpProgress;

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
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: UserAvatar(
                        imageUrl: imageUrl,
                        radius: 40,
                        onTap: () => _showImageDialog(context, imageUrl),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                                Text(
                                  hasLeveledUp
                                      ? '0/ $neededXP XP'
                                      : '$xp / $neededXP XP',
                                  style: textTheme.labelLarge,
                                ),
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
                                        FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: progress,
                                          child: Container(
                                            height: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
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
