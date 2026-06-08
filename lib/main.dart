import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TRASmartScanner());
}

class TRASmartScanner extends StatelessWidget {
  const TRASmartScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRA Smart Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

// Backwards-compatible alias for tests referencing `MyApp`.
class MyApp extends TRASmartScanner {
  const MyApp({super.key});
}