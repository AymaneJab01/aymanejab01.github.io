import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseSplitterApp());
}

/// Dark, "reactbits.dev"-style palette: near-black surfaces, a single
/// vivid green accent used sparingly for glow/gradient, and soft glass
/// borders instead of heavy elevation.
class AppColors {
  AppColors._();

  static const background = Color(0xFF0A0D0B);
  static const surface = Color(0xFF121613);
  static const surfaceRaised = Color(0xFF161C18);

  static const accent = Color(0xFF39FF88);
  static const accentDim = Color(0xFF1FA95C);
  static const accentDeep = Color(0xFF0B5D3B);

  static const border = Color(0xFF23302A);
  static const borderGlow = Color(0x5539FF88);

  static const textPrimary = Color(0xFFEAF3EE);
  static const textSecondary = Color(0xFF8FA096);
  static const textFaint = Color(0xFF5C6961);

  static const danger = Color(0xFFFF5C6C);
}

class ExpenseSplitterApp extends StatelessWidget {
  const ExpenseSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Splitter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
          surface: AppColors.surface,
        ).copyWith(
          primary: AppColors.accent,
          secondary: AppColors.accentDim,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceRaised,
          labelStyle: const TextStyle(
            color: AppColors.textSecondary,
          ),
          hintStyle: const TextStyle(
            color: AppColors.textFaint,
          ),
          prefixIconColor: AppColors.accent,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: AppColors.border,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: AppColors.accent,
              width: 1.5,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: AppColors.danger,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide(
              color: AppColors.danger,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(
              color: AppColors.accent,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceRaised,
          selectedColor: AppColors.accentDeep,
          side: const BorderSide(
            color: AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          labelStyle: const TextStyle(
            color: AppColors.textPrimary,
          ),
          secondaryLabelStyle: const TextStyle(
            color: AppColors.accent,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.surfaceRaised,
          contentTextStyle: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
