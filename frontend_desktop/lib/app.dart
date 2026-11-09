import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/state/auth_state.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/navigation/app_shell.dart';

class ApcApp extends StatelessWidget {
  const ApcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Africa Print Communication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.bleu,
          primary: AppColors.bleu,
          secondary: AppColors.orange,
          surface: AppColors.blanc,
          onSurface: AppColors.texte,
        ),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.fond,
        cardTheme: const CardThemeData(
          elevation: 0,
          color: AppColors.blanc,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side: BorderSide(color: AppColors.bord),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.orange,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.bord),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.bord),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: AppColors.bleu, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          filled: true,
          fillColor: AppColors.blanc,
        ),
      ),
      home: ListenableBuilder(
        listenable: AuthState(),
        builder: (context, _) {
          if (AuthState().isAuthenticated) {
            return const AppShell();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

