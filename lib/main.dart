import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/providers/theme_change.dart';
import 'package:notes/screen/main_screen.dart';
import "package:flutter/services.dart";


void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value)=> runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  ),);
}

final colorSchemeDark = ColorScheme.dark(
  background: Colors.black,
    primary: Colors.grey.shade900,
    secondary: Colors.grey.shade800,
  onSecondary: Colors.white38,
  onPrimary: const Color.fromARGB(255, 251, 125, 0),
);
final colorSchemeLight = ColorScheme.light(
  background: Colors.grey.shade400,
  primary: Colors.grey.shade300,
  secondary: Colors.grey.shade200,
  onSecondary: Colors.grey.shade800,
  onPrimary: Colors.blue.shade600,
);
ThemeData themeLight = ThemeData(
  brightness: Brightness.light,
  colorScheme: colorSchemeLight,
  scaffoldBackgroundColor: colorSchemeLight.background,
  appBarTheme: const AppBarTheme().copyWith(
    backgroundColor: colorSchemeLight.background,
    // foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.ubuntuCondensed(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
    foregroundColor: colorSchemeLight.onPrimary,
    backgroundColor: colorSchemeLight.primary,
  ),
  textTheme: GoogleFonts.notoSansTextTheme().copyWith(
    titleLarge: const TextStyle(color: Colors.black),
    bodyLarge:
        GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.black),
    bodyMedium:
        GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.black),
  ),
);

ThemeData themeDark = ThemeData(
  brightness: Brightness.dark,
  colorScheme: colorSchemeDark,
  scaffoldBackgroundColor: colorSchemeDark.background,
  appBarTheme: const AppBarTheme().copyWith(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    titleTextStyle: GoogleFonts.ubuntuCondensed(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
    foregroundColor: colorSchemeDark.onPrimary,
    backgroundColor: colorSchemeDark.primary,
  ),
  textTheme: GoogleFonts.notoSansTextTheme().copyWith(
    titleLarge: const TextStyle(color: Colors.white),
    bodyLarge:
        GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.white),
    bodyMedium:
        GoogleFonts.notoSans(fontWeight: FontWeight.bold, color: Colors.white),
  ),
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return MaterialApp(
      theme: theme,
      home: const MainScreen(),
    );
  }
}


// adding the binding to not allow the orientation of the device


