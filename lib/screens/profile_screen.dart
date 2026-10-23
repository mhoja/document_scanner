import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        children: [
          /// USER CARD
          FadeSlideIn(
            child: AppCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 34,
                      backgroundImage: AssetImage("assets/images/profile.jpg"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Timotheo Mhoja",
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textHigh),
                        ),
                        SizedBox(height: 4),
                        Text("TRA Officer", style: TextStyle(color: AppColors.textMedium)),
                        SizedBox(height: 2),
                        Text(
                          "Domestic Taxes Department",
                          style: TextStyle(color: AppColors.textLow, fontSize: 13),
                        ),
                        SizedBox(height: 8),
                        StatusBadge(label: "tmhoja@tra.go.tz"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// STATS CARD
          FadeSlideIn(
            index: 1,
            child: AppCard(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
                children: [
                  Expanded(child: _statItem("245", "Documents")),
                  Container(width: 1, height: 36, color: AppColors.border),
                  Expanded(child: _statItem("18", "Shared")),
                  Container(width: 1, height: 36, color: AppColors.border),
                  Expanded(child: _statItem("12", "Pending")),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          /// ACCOUNT SECTION
          const SectionHeader("Account"),
          const SizedBox(height: 12),
          FadeSlideIn(
            index: 2,
            child: _settingsGroup([
              _settingTile(Icons.lock_outline_rounded, "Change Password", () {}),
              _settingTile(Icons.fingerprint_rounded, "Biometric & Security", () {}),
              _settingTile(Icons.devices_outlined, "Devices", () {}),
            ]),
          ),

          const SizedBox(height: 26),

          /// APP SECTION
          const SectionHeader("App"),
          const SizedBox(height: 12),
          FadeSlideIn(
            index: 3,
            child: _settingsGroup([
              _settingTile(
                Icons.storage_outlined,
                "Storage Usage",
                () {},
                trailing: _trailingText("2.3 GB / 10 GB"),
              ),
              _settingTile(
                Icons.sync_rounded,
                "Sync Status",
                () {},
                trailing: _trailingText("Today 09:30 AM"),
              ),
              _settingTile(
                Icons.info_outline_rounded,
                "About TRA SecureScan",
                () {},
                trailing: _trailingText("v2.0.0"),
              ),
            ]),
          ),

          const SizedBox(height: 30),

          /// LOGOUT BUTTON
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.dangerSoft, width: 1.4),
              backgroundColor: AppColors.surface,
            ),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded),
            label: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final bool confirmed = await AppSheets.confirm(
      context,
      title: 'Log out?',
      message: 'You will need to sign in again to access your documents.',
      confirmLabel: 'Log Out',
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
      (route) => false,
    );
  }

  Widget _settingsGroup(List<Widget> tiles) {
    final List<Widget> children = [];
    for (int i = 0; i < tiles.length; i++) {
      children.add(tiles[i]);
      if (i < tiles.length - 1) {
        children.add(const Divider(indent: 68));
      }
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _trailingText(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: const TextStyle(color: AppColors.textLow, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textLow),
      ],
    );
  }

  Widget _settingTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: IconTile(icon: icon, size: 38),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textHigh)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textLow),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textHigh),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textLow, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
