import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      setState(() {
        progress += 0.015;
      });

      if (progress >= 1.0) {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double clamped = progress.clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          /// Background Decorations
          Positioned(
            top: -120,
            left: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: -180,
            right: -180,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                /// TRA Logo
                FadeSlideIn(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.lifted,
                    ),
                    child: Image.asset('assets/images/tra_logo.png', width: 110),
                  ),
                ),

                const SizedBox(height: 30),

                const FadeSlideIn(
                  index: 2,
                  child: Column(
                    children: [
                      Text(
                        "TRA SecureScan",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textHigh,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("Scan. Secure. Share.", style: TextStyle(fontSize: 16, color: AppColors.textMedium)),
                    ],
                  ),
                ),

                const SizedBox(height: 56),

                /// Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: LinearProgressIndicator(
                      value: clamped,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Loading resources… ${(clamped * 100).toInt()}%",
                  style: const TextStyle(color: AppColors.textLow, fontWeight: FontWeight.w600, fontSize: 13),
                ),

                const Spacer(),

                /// Footer
                const Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Text(
                    "Tanzania Revenue Authority",
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMedium),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
