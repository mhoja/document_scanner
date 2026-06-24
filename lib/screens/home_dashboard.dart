import 'package:flutter/material.dart';

import 'document_vault.dart';
import 'my_scans_screen.dart';
import 'profile_screen.dart';
import 'recent_document_preview_screen.dart';
import 'scan_camera_screen.dart';
import 'share_document_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int currentIndex = 0;
  bool _isSelectionModeActive = false;

  Widget _currentScreen() {
    switch (currentIndex) {
      case 0:
        return HomeDashboardContent(
          onSelectionModeChanged: (isSelecting) {
            if (_isSelectionModeActive != isSelecting) {
              setState(() {
                _isSelectionModeActive = isSelecting;
              });
            }
          },
        );
      case 1:
        return const DocumentVaultScreen();
      case 2:
        return const ScanCameraScreen();
      case 3:
        return MyScansScreen(
          onSelectionModeChanged: (isSelecting) {
            if (_isSelectionModeActive != isSelecting) {
              setState(() {
                _isSelectionModeActive = isSelecting;
              });
            }
          },
        );
      case 4:
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentScreen(),
      ),
        bottomNavigationBar: ((currentIndex == 0 || currentIndex == 3) && _isSelectionModeActive)
          ? null
          : Container(
              height: 78,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem(
                    Icons.home,
                    'Home',
                    currentIndex == 0,
                    () => setState(() => currentIndex = 0),
                  ),
                  _navItem(
                    Icons.handyman_outlined,
                    'Tools',
                    currentIndex == 1,
                    () => setState(() => currentIndex = 1),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => currentIndex = 2),
                    child: Container(
                      width: 65,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5B027),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                    ),
                  ),
                  _navItem(
                    Icons.history,
                    'Scans',
                    currentIndex == 3,
                    () => setState(() => currentIndex = 3),
                  ),
                  _navItem(
                    Icons.person_outline,
                    'Profile',
                    currentIndex == 4,
                    () => setState(() => currentIndex = 4),
                  ),
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

class HomeDashboardContent extends StatefulWidget {
  const HomeDashboardContent({super.key, this.onSelectionModeChanged});

  final ValueChanged<bool>? onSelectionModeChanged;

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

  bool get _hasSelectedDocuments => _recentDocuments.any((doc) => doc.isSelected);
  int get _selectedCount => _recentDocuments.where((doc) => doc.isSelected).length;
  bool get _canMerge => _selectedCount > 1;

  List<_RecentDocument> get _selectedDocuments =>
      _recentDocuments.where((doc) => doc.isSelected).toList();

  void _syncSelectionMode() {
    widget.onSelectionModeChanged?.call(_hasSelectedDocuments);
  }

  Future<void> _handleBulkAction(String action) async {
    if (!_hasSelectedDocuments) {
      return;
    }

    if (action == 'Share') {
      _openShareForSelectedDocuments();
      return;
    }

    if (action == 'Delete') {
      final bool shouldDelete = await _showCompactDeleteSheet(
        title: 'Delete documents',
        message: 'Delete $_selectedCount selected document(s)?',
      );

      if (!shouldDelete || !mounted) {
        return;
      }

      setState(() {
        _recentDocuments.removeWhere((doc) => doc.isSelected);
      });
      _syncSelectionMode();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected documents deleted.')),
      );
      return;
    }

    if (action == 'More') {
      _showMoreActions();
      return;
    }

    if (action == 'Rename') {
      _renameSelectedDocument();
      return;
    }

    if (action == 'Merge') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merging $_selectedCount selected document(s)...')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action for $_selectedCount selected document(s).')),
    );
  }

  Future<void> _renameSelectedDocument() async {
    final List<_RecentDocument> selectedDocuments = _selectedDocuments;
    if (selectedDocuments.length != 1) {
      return;
    }

    final _RecentDocument document = selectedDocuments.first;
    final String? updatedName = await _showCompactRenameSheet(
      initialName: document.title,
      heading: 'Rename document',
      hint: 'Enter new name',
    );

    if (updatedName == null || updatedName.isEmpty || !mounted) {
      return;
    }

    setState(() {
      document.title = updatedName;
      document.isSelected = false;
    });
    _syncSelectionMode();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document renamed successfully.')),
    );
  }

  Future<String?> _showCompactRenameSheet({
    required String initialName,
    required String heading,
    required String hint,
  }) async {
    final TextEditingController controller = TextEditingController(text: initialName);

    final String? value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 28,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      heading,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFF5E6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => Navigator.pop(sheetContext, controller.text.trim()),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFFF5E6)),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(color: Color(0xFF9A8A6E), fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF242424),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE8E8E8), width: 1.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(32),
                              side: const BorderSide(color: Color(0xFF555555)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 11, color: Color(0xFFC0C0C0))),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(sheetContext, controller.text.trim()),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(32),
                              backgroundColor: const Color(0xFFFFB800),
                              foregroundColor: const Color(0xFF1A1A1A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Save', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    final String trimmed = (value ?? '').trim();
    if (trimmed.isEmpty || trimmed == initialName) {
      return null;
    }
    return trimmed;
  }

  Future<bool> _showCompactDeleteSheet({
    required String title,
    required String message,
  }) async {
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 28,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFF5E6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: Color(0xFFD0D0D0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext, false),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(32),
                              side: const BorderSide(color: Color(0xFF555555)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Cancel', style: TextStyle(fontSize: 11, color: Color(0xFFC0C0C0))),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(sheetContext, true),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(32),
                              backgroundColor: const Color(0xFFFFB800),
                              foregroundColor: const Color(0xFF1A1A1A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Delete', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    return result == true;
  }

  void _openShareForSelectedDocuments() {
    final List<_RecentDocument> selectedDocuments = _selectedDocuments;
    if (selectedDocuments.isEmpty) {
      return;
    }

    final _RecentDocument primaryDocument = selectedDocuments.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShareDocumentScreen(
          title: primaryDocument.title,
          referenceNumber: primaryDocument.reference,
          notes: selectedDocuments.map((doc) => doc.notes).join('\n'),
          attachedImagePaths: selectedDocuments.map((doc) => doc.reference).toList(),
        ),
      ),
    );
  }

  Future<void> _showMoreActions() async {
    final String? selectedOption = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1E232B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              _moreActionTile(
                icon: Icons.photo_library_outlined,
                title: 'Save to photo',
                value: 'save_photo',
              ),
              _moreActionTile(
                icon: Icons.print_outlined,
                title: 'Print',
                value: 'print',
              ),
              _moreActionTile(
                icon: Icons.download_outlined,
                title: 'Save to PC (Download PDF)',
                value: 'download_pdf',
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selectedOption == null || !mounted) {
      return;
    }

    if (selectedOption == 'save_photo') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saving $_selectedCount selected document(s) to photo gallery...')),
      );
      return;
    }

    if (selectedOption == 'print') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Printing $_selectedCount selected document(s)...')),
      );
      return;
    }

    if (selectedOption == 'download_pdf') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading $_selectedCount selected document(s) as PDF...')),
      );
    }
  }

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
            _syncSelectionMode();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, _hasSelectedDocuments ? 96 : 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5B027),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Good morning.', style: TextStyle(color: Colors.black87, fontSize: 14)),
                          SizedBox(height: 4),
                          Text(
                            'John M. Komba',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(height: 2),
                          Text('TRA Officer', style: TextStyle(color: Colors.black87, fontSize: 14)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_none, size: 30, color: Colors.white),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage('assets/images/profile.png'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF050505),
                              Color(0xFF111111),
                              Color(0xFF000000),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white24, width: 1.1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.65),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(Icons.cloud_off_outlined, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('You are offline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                  SizedBox(height: 2),
                                  Text(
                                    'Your changes will sync when connection is restored.',
                                    style: TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.chevron_right, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 86,
                            child: _statCard('245', 'Documents'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 86,
                            child: _statCard('12', 'Pending Sync'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 86,
                            child: _statCard('6', 'Shared Today'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _quickAction(Icons.camera_alt, 'Scan Document', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanCameraScreen()));
                        }),
                        _quickAction(Icons.handyman_outlined, 'Open Tools', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentVaultScreen()));
                        }),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text('Recent Documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
        ),
        if (_hasSelectedDocuments)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                height: 78,
                decoration: const BoxDecoration(
                  color: Color(0xFF20242B),
                  border: Border(top: BorderSide(color: Color(0xFF2E333C))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _bottomAction(Icons.share_outlined, 'Share', () => _handleBulkAction('Share')),
                    _bottomAction(Icons.drive_file_move_outline, 'Move/Copy', () => _handleBulkAction('Move/Copy')),
                    _bottomAction(
                      _canMerge ? Icons.merge_type : Icons.drive_file_rename_outline,
                      _canMerge ? 'Merge' : 'Rename',
                      () => _handleBulkAction(_canMerge ? 'Merge' : 'Rename'),
                    ),
                    _bottomAction(Icons.delete_outline, 'Delete', () => _handleBulkAction('Delete')),
                    _bottomAction(Icons.more_horiz, 'More', () => _handleBulkAction('More')),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statCard(String number, String label) {
    IconData icon;
    Color accentColor;
    List<Color> surfaceColors;
    Color borderColor;

    if (label.contains('Documents')) {
      icon = Icons.description_outlined;
      accentColor = const Color(0xFF2F6BFF);
      surfaceColors = const [Color(0xFFF7FAFF), Color(0xFFEDF3FF), Color(0xFFF9FBFF)];
      borderColor = const Color(0xFFD6E4FF);
    } else if (label.contains('Pending')) {
      icon = Icons.cloud_sync_outlined;
      accentColor = const Color(0xFF0EA5A4);
      surfaceColors = const [Color(0xFFF4FFFD), Color(0xFFE9FFFB), Color(0xFFF6FFFD)];
      borderColor = const Color(0xFFCDEFEA);
    } else {
      icon = Icons.share_outlined;
      accentColor = const Color(0xFF7C5CFF);
      surfaceColors = const [Color(0xFFF8F6FF), Color(0xFFF1EDFF), Color(0xFFFBFAFF)];
      borderColor = const Color(0xFFE1D8FF);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: surfaceColors,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            blurRadius: 22,
            offset: const Offset(-2, -2),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: -14,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF141414),
                        letterSpacing: -0.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF3F3F3F),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF),
                      accentColor.withValues(alpha: 0.14),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.9),
                      blurRadius: 12,
                      offset: const Offset(-1, -1),
                    ),
                  ],
                ),
                  child: Icon(icon, color: accentColor, size: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String title, VoidCallback onTap) {
    Color accentColor;
    List<Color> surfaceColors;
    Color borderColor;

    if (title.contains('Scan')) {
      accentColor = const Color(0xFF2F6BFF);
      surfaceColors = const [Color(0xFFF7FAFF), Color(0xFFEDF3FF), Color(0xFFF9FBFF)];
      borderColor = const Color(0xFFD6E4FF);
    } else {
      accentColor = const Color(0xFF0EA5A4);
      surfaceColors = const [Color(0xFFF4FFFD), Color(0xFFE9FFFB), Color(0xFFF6FFFD)];
      borderColor = const Color(0xFFCDEFEA);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: surfaceColors,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.95),
                blurRadius: 22,
                offset: const Offset(-2, -2),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: 0.16),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF),
                      accentColor.withValues(alpha: 0.14),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.9),
                      blurRadius: 12,
                      offset: const Offset(-1, -1),
                    ),
                  ],
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.2,
                    color: Color(0xFF141414),
                    letterSpacing: -0.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _documentTile(BuildContext context, _RecentDocument document) {
    final bool isSelected = document.isSelected;
    final Color cardColor = isSelected ? const Color(0xFFEBF4FE) : Colors.white;
    final Color primaryTextColor = isSelected ? const Color(0xFF1A1F2E) : const Color(0xFF111827);
    final Color secondaryTextColor = isSelected ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
    final Color borderColor = isSelected ? const Color(0xFF2F6BFF) : const Color(0xFFD6E7FB);
    final Color iconBgColor = isSelected ? const Color(0xFFD6E7FB) : const Color(0xFFF0F4FF);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openPreview(context, document),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.3),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.95),
              blurRadius: isSelected ? 22 : 18,
              offset: const Offset(-2, -2),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFFC0D9F7) : const Color(0xFFE0E9F8),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.picture_as_pdf,
                color: isSelected ? const Color(0xFF2F6BFF) : const Color(0xFF4B82FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: primaryTextColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${document.reference} • ${document.time}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2F6BFF).withOpacity(0.15) : const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'PDF',
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2F6BFF) : const Color(0xFF10B981),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 42,
              height: 42,
              child: Checkbox(
                value: document.isSelected,
                onChanged: (checked) {
                  setState(() {
                    document.isSelected = checked ?? false;
                  });
                  _syncSelectionMode();
                },
                activeColor: const Color(0xFFF5B027),
                checkColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? const Color(0xFFF5B027) : const Color(0xFFD1D5DB),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _moreActionTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      onTap: () => Navigator.pop(context, value),
    );
  }
}

class _RecentDocument {
  _RecentDocument({
    required this.title,
    required this.reference,
    required this.time,
    required this.notes,
    this.isSelected = false,
  });

  String title;
  final String reference;
  final String time;
  final String notes;
  bool isSelected;
}