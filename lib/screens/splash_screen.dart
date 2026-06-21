// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'login_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   double progress = 0.0;

//   @override
//   void initState() {
//     super.initState();

//     // Animate progress bar from 0% to 100%
//     Timer.periodic(const Duration(milliseconds: 40), (timer) {
//       setState(() {
//         progress += 0.02; // Smooth increase
//         if (progress >= 1.0) {
//           timer.cancel();
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (_) => const LoginScreen()),
//           );
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: Stack(
//         children: [
//           /// Background Decorative Elements
//           Positioned(
//             top: -100,
//             left: -100,
//             child: Container(
//               width: 300,
//               height: 300,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFF003087).withOpacity(0.08),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -150,
//             right: -150,
//             child: Container(
//               width: 400,
//               height: 400,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFFF4B400).withOpacity(0.1),
//               ),
//             ),
//           ),

//           SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Spacer(),

//                 /// TRA Logo
//                 Image.asset(
//                   'assets/images/tra_logo.png',
//                   width: 160,
//                 ),

//                 const SizedBox(height: 30),

//                 /// App Name
//                 const Text(
//                   "TRA SecureScan",
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF003087),
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 const Text(
//                   "Scan. Secure. Share.",
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),

//                 const SizedBox(height: 60),

//                 /// Progress Bar Section
//                 Column(
//                   children: [
//                     const Text(
//                       "Resource Loading...",
//                       style: TextStyle(fontSize: 15, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 12),

//                     /// Progress Bar
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 40),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: LinearProgressIndicator(
//                           value: progress,
//                           minHeight: 10,
//                           backgroundColor: const Color(0xFFF4B400),
//                           valueColor: const AlwaysStoppedAnimation<Color>(
//                             Color(0xFF000000), // Gold color like your image
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     /// Percentage Text
//                     Text(
//                       "${(progress * 100).toInt()}%",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF003087),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const Spacer(),

//                 /// Footer
//                 const Padding(
//                   padding: EdgeInsets.only(bottom: 30),
//                   child: Text(
//                     "Tanzania Revenue Authority",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF003087),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(milliseconds: 35), (timer) {
      setState(() {
        progress += 0.015;
        if (progress >= 1.0) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          /// Background Decorations
          Positioned(top: -120, left: -120, child: CircleAvatar(radius: 150, backgroundColor: const Color(0xFF003087).withOpacity(0.06))),
          Positioned(bottom: -180, right: -180, child: CircleAvatar(radius: 200, backgroundColor: const Color(0xFFF4B400).withOpacity(0.08))),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                /// TRA Logo
                Image.asset('assets/images/tra_logo.png', width: 160),

                const SizedBox(height: 30),

                const Text(
                  "TRA SecureScan",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF003087)),
                ),

                const SizedBox(height: 8),
                const Text("Scan. Secure. Share.", style: TextStyle(fontSize: 16, color: Colors.grey)),

                const SizedBox(height: 60),

                /// Dashed Border Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// Dashed Border Container
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFF003087),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),

                      /// Inner Progress
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.transparent,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF4B400)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// Percentage
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003087),
                  ),
                ),

                const SizedBox(height: 8),
                const Text("Resource Loading...", style: TextStyle(color: Colors.grey)),

                const Spacer(),

                /// Footer
                const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Text(
                    "Tanzania Revenue Authority",
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF003087)),
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