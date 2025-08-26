import '../exports/package_exports.dart';

//pink 0xFFFFB7C5, red 0xFFFF9999, orange 0xFFFFD1A6, yellow 0xFFFFEE99, green 0xFFBFFFBF, turqoise 0xFFBFFFF0, blue 0xFFBFDFFF, dark blue 0xFFA6AAFF, purple 0xFFD1B3FF

class ThemePreset {
  final String name;
  final Color primary;
  final Color secondary;
  final Color tertiary;

  ThemePreset({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });
}

final List<ThemePreset> presets = [
  ThemePreset(
      name: 'Pink',
      primary: Color(0xFFFFB7C5),
      secondary: Color(0xFFFF8098),
      tertiary: Color(0xFFBF6072)),
  ThemePreset(
      name: 'Red',
      primary: Color(0xFFFF9999),
      secondary: Color(0xFFFF6666),
      tertiary: Color(0xFFBF3939)),
  ThemePreset(
      name: 'Orange',
      primary: Color(0xFFFFD1A6),
      secondary: Color(0xFFFFB066),
      tertiary: Color(0xFFBF844D)),
  ThemePreset(
      name: 'Yellow',
      primary: Color(0xFFFFEE99),
      secondary: Color(0xFFFFE666),
      tertiary: Color(0xFFBFAC4D)),
  ThemePreset(
      name: 'Green',
      primary: Color(0xFFBFFFBF),
      secondary: Color(0xFF80FF80),
      tertiary: Color(0xFF60BF60)),
  ThemePreset(
      name: 'Turquoise',
      primary: Color(0xFFBFFFF0),
      secondary: Color(0xFF80FFE1),
      tertiary: Color(0xFF60BFA8)),
  ThemePreset(
      name: 'Blue',
      primary: Color(0xFFBFDFFF),
      secondary: Color(0xFF80BEFF),
      tertiary: Color(0xFF608FBF)),
  ThemePreset(
      name: 'Dark Blue',
      primary: Color(0xFFA6AAFF),
      secondary: Color(0xFF666EFF),
      tertiary: Color(0xFF4D52BF)),
  ThemePreset(
      name: 'Purple',
      primary: Color(0xFFD1B3FF),
      secondary: Color(0xFFB280FF),
      tertiary: Color(0xFF8560BF)),
];
