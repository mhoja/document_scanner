import 'package:flutter/material.dart';

import 'home_dashboard.dart';
import 'document_vault.dart';
import 'scan_camera_screen.dart';
import 'profile_screen.dart';
import 'my_scans_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeDashboard(),
    DocumentVaultScreen(),
    ScanCameraScreen(),
    MyScansScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFEAEAEA),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceAround,
          children: [

            _navItem(
              icon: Icons.home,
              label: "Home",
              index: 0,
            ),

            _navItem(
              icon: Icons.folder_copy_outlined,
              label: "Vault",
              index: 1,
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  currentIndex = 2;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF2F6BFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
              ),
            ),

            _navItem(
              icon: Icons.people_outline,
              label: "Shared",
              index: 3,
            ),

            _navItem(
              icon: Icons.person_outline,
              label: "Profile",
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    bool selected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            color: selected
                ? const Color(0xFF2F6BFF)
                : Colors.grey,
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF2F6BFF)
                  : Colors.grey,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}