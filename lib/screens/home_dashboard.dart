

import 'package:flutter/material.dart';
import 'scan_camera_screen.dart';
import 'document_vault.dart';
import 'my_scans_screen.dart';
import 'profile_screen.dart';
import 'recent_document_preview_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HomeDashboardContent(), // We'll keep main content here
    const DocumentVaultScreen(),
    const ScanCameraScreen(),
    const MyScansScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: screens[currentIndex],
      ),

      /// Bottom Navigation
      bottomNavigationBar: Container(
        height: 78,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", currentIndex == 0, () => setState(() => currentIndex = 0)),
            _navItem(Icons.folder_copy_outlined, "Vault", currentIndex == 1, () => setState(() => currentIndex = 1)),
            
            // Big Scan Button
            GestureDetector(
              onTap: () => setState(() => currentIndex = 2),
              child: Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Color(0xFF2F6BFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
              ),
            ),

            _navItem(Icons.history, "Scans", currentIndex == 3, () => setState(() => currentIndex = 3)),
            _navItem(Icons.person_outline, "Profile", currentIndex == 4, () => setState(() => currentIndex = 4)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String title, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? const Color(0xFF2F6BFF) : Colors.grey),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: active ? const Color(0xFF2F6BFF) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted Main Content (to avoid duplication)
class HomeDashboardContent extends StatefulWidget {
  const HomeDashboardContent({super.key});

  @override
  State<HomeDashboardContent> createState() => _HomeDashboardContentState();
}

class _HomeDashboardContentState extends State<HomeDashboardContent> {
  final List<_RecentDocument> _recentDocuments = <_RecentDocument>[
    _RecentDocument(
      title: 'Tax Compliance Guidelines',
      reference: 'TCG/2026/001',
      time: '10:20 AM',
      notes: 'Recent tax compliance policy circular.',
    ),
    _RecentDocument(
      title: 'HR Circular - Leave Policy',
      reference: 'HR/CIR/2026/01',
      time: '09:10 AM',
      notes: 'Updated internal leave process and approvals.',
    ),
    _RecentDocument(
      title: 'Office Memorandum',
      reference: 'TRADM/2024/045',
      time: '08:45 AM',
      notes: 'Office timings memorandum for all staff.',
    ),
  ];

  Future<void> _confirmDelete(BuildContext context, _RecentDocument document) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${document.title}" from recent documents?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      setState(() {
        _recentDocuments.remove(document);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted.')),
      );
    }
  }

  Future<void> _showEditNameDialog(BuildContext context, _RecentDocument document) async {
    final TextEditingController controller = TextEditingController(text: document.title);

    final String? updatedName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Document Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Document name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updatedName != null && updatedName.isNotEmpty && mounted) {
      setState(() {
        document.title = updatedName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document name updated.')),
      );
    }
  }

  void _openPreview(BuildContext context, _RecentDocument document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecentDocumentPreviewScreen(
          title: document.title,
          referenceNumber: document.reference,
          timestamp: document.time,
          notes: document.notes,
          onDelete: () {
            setState(() {
              _recentDocuments.remove(document);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// COLORED HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF022A78),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Good morning.", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      SizedBox(height: 4),
                      Text("John M. Komba", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 2),
                      Text("TRA Officer", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Stack(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, size: 30, color: Colors.white)),
                        Positioned(right: 10, top: 10, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const CircleAvatar(radius: 24, backgroundImage: AssetImage("assets/images/profile.png")),
                  ],
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, -18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// OFFLINE CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: const Color(0xFFFFF8EB), borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                const Icon(Icons.cloud_off_outlined, color: Color(0xFF0A1F44)),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("You are offline", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 4),
                      Text("Your changes will sync when connection is restored.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// STATS
          Row(
            children: [
              Expanded(child: _statCard("245", "Documents")),
              const SizedBox(width: 12),
              Expanded(child: _statCard("12", "Pending Sync")),
              const SizedBox(width: 12),
              Expanded(child: _statCard("6", "Shared Today")),
            ],
          ),

          const SizedBox(height: 24),

          /// QUICK ACTIONS
          const Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 14),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _quickAction(Icons.camera_alt, Colors.blue, "Scan Document", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanCameraScreen()));
              }),
              _quickAction(Icons.folder, Colors.amber, "Open Vault", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentVaultScreen()));
              }),
              _quickAction(Icons.people_alt, Colors.indigo, "Share Within TRA", () {}),
              _quickAction(Icons.download, Colors.green, "Download Center", () {}),
            ],
          ),

          const SizedBox(height: 28),

          /// RECENT DOCUMENTS
          const Text("Recent Documents", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 14),
          if (_recentDocuments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No recent documents available.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._recentDocuments.map((doc) => _documentTile(context, doc)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        children: [
          Text(number, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, Color color, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1F1F1)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  Widget _documentTile(
    BuildContext context,
    _RecentDocument document,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openPreview(context, document),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(color: const Color(0xFFF4F4F4), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.picture_as_pdf, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    '${document.reference} • ${document.time}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
              child: const Text("PDF", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'preview') {
                  _openPreview(context, document);
                } else if (value == 'edit') {
                  _showEditNameDialog(context, document);
                } else if (value == 'delete') {
                  _confirmDelete(context, document);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem<String>(
                  value: 'preview',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.visibility_outlined),
                    title: Text('Preview & Share'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit Name'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.delete_outline, color: Colors.redAccent),
                    title: Text('Delete'),
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentDocument {
  _RecentDocument({
    required this.title,
    required this.reference,
    required this.time,
    required this.notes,
  });

  String title;
  final String reference;
  final String time;
  final String notes;
}