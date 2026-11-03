import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/lock_manager.dart';
import 'widgets/reboot_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await lockManager.loadLocks();
  runApp(const RebootApp());
}

class RebootApp extends StatelessWidget {
  const RebootApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Reboot',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RebootColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: RebootColors.purple,
        secondary: RebootColors.mint,
        surface: RebootColors.panel,
        onSurface: RebootColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: false,
        foregroundColor: RebootColors.text,
        titleTextStyle: TextStyle(color: RebootColors.text, fontSize: 17, fontWeight: FontWeight.w700),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: RebootColors.text, fontSize: 34, height: 1.08, fontWeight: FontWeight.w800, letterSpacing: -1.2),
        headlineMedium: TextStyle(color: RebootColors.text, fontSize: 26, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -.6),
        titleLarge: TextStyle(color: RebootColors.text, fontSize: 18, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: RebootColors.text, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: RebootColors.muted, fontSize: 13, height: 1.5),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: RebootColors.panel2, contentTextStyle: const TextStyle(color: RebootColors.text),
        behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    home: const HomeScreen(),
  );
}
