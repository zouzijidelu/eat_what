import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_colors.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const EatWhatApp());
}

class EatWhatApp extends StatelessWidget {
  const EatWhatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '吃啥',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand500,
          brightness: Brightness.light,
          primary: AppColors.brand500,
          secondary: AppColors.brand600,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: null,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.ink),
          bodyMedium: TextStyle(color: AppColors.ink),
          bodySmall: TextStyle(color: AppColors.ink),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
