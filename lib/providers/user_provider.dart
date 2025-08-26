import '../exports/package_exports.dart';
import '../exports/theme_exports.dart';
import '../exports/util_exports.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _imageUrl;
  String? _cachedDisplayName;
  String get imageUrl => _imageUrl ?? '';
  String get cachedDisplayName => _cachedDisplayName ?? 'User';

  int _level = 0;
  int _xp = 0;
  int get level => _level;
  int get xp => _xp;

  late ThemeData _themeData;
  late String _themeName;
  late Brightness _brightness;
  String get themeName => _themeName;
  Brightness get brightness => _brightness;
  ThemeData get themeData => _themeData;

  UserProvider() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await loadUserData();
      } else {
        applyFallbackTheme();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          clearProfile();
        });
      }
    });

    final fallbackPreset = getThemePreset('Purple');
    _themeData =
        buildCustomTheme(preset: fallbackPreset, brightness: Brightness.light);
    _themeName = 'Purple';
    _brightness = Brightness.light;
  }

  bool _hasLoadedData = false;
  bool get hasLoadedData => _hasLoadedData;

  Future<void> loadUserData() async {
    if (_hasLoadedData) return;

    final user = _auth.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();

    final fallbackName = user?.displayName ?? 'User';

    if (data != null) {
      _imageUrl = data['profileImageUrl'];
      _cachedDisplayName = data['displayName'] ?? fallbackName;

      _level = data['level'] ?? 0;
      _xp = data['xp'] ?? 0;

      _themeName = data['themeName'] ?? 'Purple';
      final brightnessString = data['brightness'] ?? 'light';
      _brightness =
          brightnessString == 'dark' ? Brightness.dark : Brightness.light;

      final preset = getThemePreset(_themeName);
      _themeData = buildCustomTheme(preset: preset, brightness: _brightness);
    } else {
      _cachedDisplayName = fallbackName;
      _themeName = 'Purple';
      _brightness = Brightness.light;
      _themeData = buildCustomTheme(
          preset: getThemePreset('Purple'), brightness: Brightness.light);
    }

    _hasLoadedData = true;
    notifyListeners();
    debugLog('[UserProvider] User data loaded for user: ${user?.email}');
  }

  Future<void> updateProfile({String? displayName, String? imageUrl}) async {
    final user = _auth.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    if (displayName != null) {
      _cachedDisplayName = displayName;
      await user!.updateDisplayName(displayName);
    }

    if (imageUrl != null) {
      _imageUrl = imageUrl;
    }

    await _firestore.collection('users').doc(uid).set({
      if (displayName != null) 'displayName': displayName,
      if (imageUrl != null) 'profileImageUrl': imageUrl,
    }, SetOptions(merge: true));

    notifyListeners();
    debugLog('[UserProvider] Profile updated');
  }

  int levelUpXP(int level) {
    return 100 + (level * 50);
  }

  int get neededXP => levelUpXP(level);
  bool get hasLeveledUp => xp >= neededXP;
  double get xpProgress {
    if (_xp >= neededXP) return 0.0;
    return (_xp / neededXP).clamp(0.0, 1.0);
  }

  Future<void> addXP(int amount) async {
    final user = _auth.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    _xp += amount;

    bool leveledUp = false;

    while (_xp >= levelUpXP(_level)) {
      _xp -= levelUpXP(_level);
      _level += 1;
      leveledUp = true;
    }

    await _firestore.collection('users').doc(uid).set({
      'xp': _xp,
      'level': _level,
    }, SetOptions(merge: true));

    notifyListeners();
    debugLog('[UserProvider] Added $amount XP, now $_xp');
    if (leveledUp) {
      debugLog('[UserProvider] User leveled up! Now level $_level');
    }
  }

  Future<void> updateLevel(int newLevel) async {
    final user = _auth.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    _level = newLevel;
    await _firestore.collection('users').doc(uid).set({
      'level': newLevel,
    }, SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> updateXP(int newXP) async {
    final user = _auth.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    _xp = newXP;
    await _firestore.collection('users').doc(uid).set({
      'xp': newXP,
    }, SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> updateTheme(String themeName, {Brightness? brightness}) async {
    final user = _auth.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    _themeName = themeName;
    _brightness = brightness ?? _brightness;

    final preset = getThemePreset(_themeName);
    _themeData = buildCustomTheme(preset: preset, brightness: _brightness);

    await _firestore.collection('users').doc(uid).set({
      'themeName': _themeName,
      'brightness': _brightness.name,
    }, SetOptions(merge: true));

    notifyListeners();
    debugLog('[UserProvider] Theme updated');
  }

  void clearProfile() {
    _imageUrl = null;
    _cachedDisplayName = null;
    _hasLoadedData = false;
    notifyListeners();
    debugLog('[UserProvider] Profile cleared');
  }

  Future<void> applyFallbackTheme() async {
    final fallbackPreset = getThemePreset('Purple');
    _themeData =
        buildCustomTheme(preset: fallbackPreset, brightness: Brightness.light);
    _themeName = 'Purple';
    _brightness = Brightness.light;
    notifyListeners();
    debugLog('[UserProvider] Applied fallback theme');
  }
}
