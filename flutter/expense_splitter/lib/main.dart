import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseSplitterApp());
}

class ExpenseSplitterApp extends StatelessWidget {
  const ExpenseSplitterApp({super.key});

  static const Color deepGreen = Color(0xFF0B5D3B);
  static const Color lightGreen = Color(0xFFE8F5EE);
  static const Color background = Color(0xFFF6F9F7);
  static const Color border = Color(0xFFDCE7E1);
  static const Color darkText = Color(0xFF17231D);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Splitter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        colorScheme: ColorScheme.fromSeed(
          seedColor: deepGreen,
          brightness: Brightness.light,
        ).copyWith(
          primary: deepGreen,
          onPrimary: Colors.white,
          secondary: deepGreen,
          surface: Colors.white,
        ),

        scaffoldBackgroundColor: background,

        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
        ),

        inputDecorationTheme:
            InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,

          labelStyle: const TextStyle(
            color: Color(0xFF64736B),
          ),

          hintStyle: const TextStyle(
            color: Color(0xFFA0ABA5),
          ),

          prefixIconColor: deepGreen,

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: border,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: border,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: deepGreen,
              width: 1.5,
            ),
          ),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        filledButtonTheme:
            FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: deepGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),
        ),

        textButtonTheme:
            TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: deepGreen,
          ),
        ),

        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: lightGreen,
          side: const BorderSide(
            color: border,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
          labelStyle:
              const TextStyle(
            color: darkText,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
