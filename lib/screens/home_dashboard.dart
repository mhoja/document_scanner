import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'scan_camera_screen.dart';
import 'my_scans_screen.dart';
import 'profile_screen.dart';
import 'document_detail_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final String officerName = "Timotheo E. Mhoja";
  final String position = "TRA Officer II";

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final accent = AppColors.secondary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 260,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Good morning,",
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                officerName,
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                position,
                                style: const TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications, color: Colors.white),
                              onPressed: () {},
                            ),
                            const SizedBox(height: 8),
                            const CircleAvatar(
                              radius: 24,
                              backgroundImage: AssetImage('assets/images/tra_logo.png'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 14),
                          Icon(Icons.search, color: AppColors.textLow, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search documents',
                                hintStyle: TextStyle(color: AppColors.textLow, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatCard("Total Documents", "128", primary, AppColors.surface, valueColor: primary),
                        const SizedBox(width: 16),
                        _buildStatCard("Pending Sync", "12", AppColors.danger, AppColors.surface, valueColor: AppColors.danger),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick Filters Section
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip("All Documents", "128", AppColors.primary, true),
                          const SizedBox(width: 12),
                          _buildFilterChip("Pending", "12", AppColors.danger, false),
                          const SizedBox(width: 12),
                          _buildFilterChip("Synced", "116", AppColors.success, false),
                          const SizedBox(width: 12),
                          _buildUploadChip(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Documents",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyScansScreen()),
                            );
                          },
                          child: Text('View all', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildRecentDocument("Circular on Working Hours", "20 May 2024, 09:30 AM", "Pending", primary, accent),
                          _buildRecentDocument("Office Notice - 05/2024", "19 May 2024, 04:45 PM", "Synced", primary, accent),
                          _buildRecentDocument("Meeting Minutes - HR", "18 May 2024, 11:20 AM", "Pending", primary, accent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 92,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home, 'Home', true, () {}),
                      _buildNavItem(Icons.history, 'My Scans', false, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyScansScreen()));
                      }),
                      const SizedBox(width: 80),
                      _buildNavItem(Icons.person, 'Profile', false, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                      }),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 14, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ScanCameraScreen()),
                          );
                        },
                        icon: Icon(Icons.qr_code_scanner, color: primary, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color titleColor, Color backgroundColor, {Color valueColor = Colors.black}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: titleColor)),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool selected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.textLow, size: 28),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: selected ? AppColors.primary : AppColors.textLow, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String count, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.12) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color : AppColors.border,
          width: 1.5,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))]
            : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isActive ? color : AppColors.textMedium)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? color : AppColors.textLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(count, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? Colors.white : AppColors.surface)),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_upload_outlined, color: AppColors.secondary, size: 18),
          const SizedBox(width: 8),
          Text('Upload', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _buildRecentDocument(String title, String date, String status, Color navy, Color yellow) {
    final bool isPending = status.toLowerCase() == 'pending';
    return Dismissible(
      key: Key(title),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete_outline, color: AppColors.danger, size: 28),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
      onDismissed: (DismissDirection direction) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$title" deleted'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.danger,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DocumentDetailScreen(
                  title: title,
                  date: date,
                  status: status,
                  referenceNumber: title == 'Circular on Working Hours' ? 'TRA/ADM/2024/05' : 'TRA/ADM/2024/06',
                  notes: title == 'Circular on Working Hours'
                      ? 'This circular outlines the new office working hours effective from 21st May 2024.'
                      : 'This is a saved scan document from the TRA system.',
                  scannedBy: officerName,
                ),
              ),
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: navy.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.description, color: AppColors.primary),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(date, style: const TextStyle(color: AppColors.textMedium)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPending ? yellow.withOpacity(0.16) : AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: isPending ? AppColors.danger : AppColors.success, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == 'rename') {
                      _showRenameDialog(context, title);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, title);
                    } else if (value == 'share') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sharing "$title"'), duration: const Duration(seconds: 2)),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                          SizedBox(width: 12),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, size: 20, color: AppColors.secondary),
                          SizedBox(width: 12),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMedium),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 160),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, String currentTitle) {
    final TextEditingController controller = TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename Document', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: const TextStyle(color: AppColors.textLow),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"$currentTitle" renamed to "${controller.text}"'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Rename', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Document?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$title" deleted'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: AppColors.danger,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
