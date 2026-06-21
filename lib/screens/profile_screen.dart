import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF0A1F44),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF0A1F44),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// USER CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.03),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Row(
                children: [

                  const CircleAvatar(
                    radius: 36,
                    backgroundImage:
                    AssetImage("assets/images/profile.png"),
                  ),

                  const SizedBox(width: 16),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Timotheo Mhoja",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "TRA Officer",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Domestic Taxes Department",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "tmhoja@tra.go.tz",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ACCOUNT SECTION
            _sectionTitle("Account"),

            const SizedBox(height: 12),

            _settingTile(
              Icons.lock_outline,
              "Change Password",
              () {},
            ),

            _settingTile(
              Icons.fingerprint,
              "Biometric & Security",
              () {},
            ),

            _settingTile(
              Icons.devices_outlined,
              "Devices",
              () {},
            ),

            const SizedBox(height: 24),

            /// APP SECTION
            _sectionTitle("App"),

            const SizedBox(height: 12),

            _settingTile(
              Icons.storage_outlined,
              "Storage Usage",
              () {},
              trailing:
              const Text("2.3 GB / 10 GB"),
            ),

            _settingTile(
              Icons.sync,
              "Sync Status",
              () {},
              trailing: const Text(
                "Last Sync\nToday 09:30 AM",
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),

            _settingTile(
              Icons.info_outline,
              "About TRA SecureScan",
              () {},
              trailing: const Text("v2.0.0"),
            ),

            const SizedBox(height: 24),

            /// STATS CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(22),
              ),
              child: Column(
                children: [

                  const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [

                      Text(
                        "Statistics",
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [

                      Expanded(
                        child: _statItem(
                          "245",
                          "Documents",
                        ),
                      ),

                      Expanded(
                        child: _statItem(
                          "18",
                          "Shared",
                        ),
                      ),

                      Expanded(
                        child: _statItem(
                          "12",
                          "Pending",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.red,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Log Out",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _settingTile(
      IconData icon,
      String title,
      VoidCallback onTap, {
        Widget? trailing,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: const Color(0xFF2F6BFF),
        ),
        title: Text(title),
        trailing:
        trailing ??
            const Icon(
              Icons.chevron_right,
            ),
      ),
    );
  }

  Widget _statItem(
      String value,
      String label,
      ) {
    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F6BFF),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}