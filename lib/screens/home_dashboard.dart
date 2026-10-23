import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/document_registry.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/document_id_card.dart';
import 'document_vault.dart';
import 'my_scans_screen.dart';
import 'profile_screen.dart';
import 'recent_document_preview_screen.dart';
import 'scan_camera_screen.dart';
import 'share_document_screen.dart';
import 'verify_document_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int currentIndex = 0;
  bool _isSelectionModeActive = false;

  void _onSelectionModeChanged(bool isSelecting) {
    if (_isSelectionModeActive != isSelecting) {
      setState(() {
        _isSelectionModeActive = isSelecting;
      });
    }
  }

  Widget _currentScreen() {
    switch (currentIndex) {
      case 0:
        return HomeDashboardContent(onSelectionModeChanged: _onSelectionModeChanged);
      case 1:
        return const DocumentVaultScreen();
      case 2:
        return const ScanCameraScreen();
      case 3:
        return MyScansScreen(onSelectionModeChanged: _onSelectionModeChanged);
      case 4:
      default:
        return const ProfileScreen();
    }
  }

  void _selectTab(int index) {
    if (index == currentIndex) {
      return;
    }
    setState(() {
      currentIndex = index;
      _isSelectionModeActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hideNav = (currentIndex == 0 || currentIndex == 3) && _isSelectionModeActive;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(key: ValueKey<int>(currentIndex), child: _currentScreen()),
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: hideNav ? const SizedBox(width: double.infinity) : _buildNavBar(),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: [
              _navItem(Icons.home_rounded, 'Home', 0),
              _navItem(Icons.handyman_outlined, 'Tools', 1),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => _selectTab(2),
                    child: AnimatedScale(
                      scale: currentIndex == 2 ? 1.06 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.glow(AppColors.primary),
                        ),
                        child: const Icon(Icons.document_scanner_rounded, color: AppColors.onPrimary, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
              _navItem(Icons.history_rounded, 'Scans', 3),
              _navItem(Icons.person_outline_rounded, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String title, int index) {
    final bool active = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _selectTab(index),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: active ? AppColors.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: active ? AppColors.onPrimary : AppColors.textLow, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.textHigh : AppColors.textLow,
              ),
            ),
          ],
        ),
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

  /// IDs of saved scans already in the list, so a reload only adds new ones
  /// and keeps the user's renames and deletions for this session.
  final Set<String> _loadedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadSavedScans();
  }

  Future<void> _loadSavedScans() async {
    final List<ScannedDocumentRecord> records = await DocumentRegistry.instance.all();
    if (!mounted) {
      return;
    }

    final List<_RecentDocument> newDocuments = records
        .where((record) => !_loadedIds.contains(record.id))
        .map(
          (record) => _RecentDocument(
            title: record.title,
            reference: record.referenceNumber,
            time: _formatTime(record.issuedAt),
            notes: record.notes,
            record: record,
          ),
        )
        .toList();
    if (newDocuments.isEmpty) {
      return;
    }

    setState(() {
      _loadedIds.addAll(newDocuments.map((doc) => doc.record!.id));
      _recentDocuments.insertAll(0, newDocuments);
    });
  }

  static String _formatTime(DateTime time) {
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
  }

  bool get _hasSelectedDocuments => _recentDocuments.any((doc) => doc.isSelected);
  int get _selectedCount => _recentDocuments.where((doc) => doc.isSelected).length;
  bool get _canMerge => _selectedCount > 1;

  List<_RecentDocument> get _selectedDocuments => _recentDocuments.where((doc) => doc.isSelected).toList();

  String get _greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  void _syncSelectionMode() {
    widget.onSelectionModeChanged?.call(_hasSelectedDocuments);
  }

  void _clearSelection() {
    setState(() {
      for (final _RecentDocument doc in _recentDocuments) {
        doc.isSelected = false;
      }
    });
    _syncSelectionMode();
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
      final bool shouldDelete = await AppSheets.confirm(
        context,
        title: 'Delete documents?',
        message: 'Delete $_selectedCount selected document(s)? This cannot be undone.',
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
      _mergeSelectedDocuments();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action for $_selectedCount selected document(s).')),
    );
  }

  Future<void> _mergeSelectedDocuments() async {
    final List<_RecentDocument> selectedDocuments = _selectedDocuments;
    final List<_RecentDocument> withoutPages = selectedDocuments.where((doc) => doc.record == null).toList();
    if (withoutPages.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Only scanned documents can be merged. "${withoutPages.first.title}" has no scanned pages.')),
      );
      return;
    }

    final String? title = await AppSheets.textInput(
      context,
      title: 'Merge ${selectedDocuments.length} documents',
      initialValue: selectedDocuments.map((doc) => doc.title).join(' + '),
      hint: 'Name of the merged document',
      confirmLabel: 'Merge',
      allowUnchanged: true,
    );
    if (title == null || title.trim().isEmpty || !mounted) {
      return;
    }

    final ScannedDocumentRecord merged;
    try {
      merged = await DocumentRegistry.instance.merge(
        selectedDocuments.map((doc) => doc.record!).toList(),
        title: title.trim(),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not merge the documents. Please try again.')),
        );
      }
      return;
    }
    if (!mounted) {
      return;
    }

    _clearSelection();
    await _loadSavedScans();
    if (!mounted) {
      return;
    }

    await showDocumentIdSheet(
      context,
      merged,
      title: 'Documents Merged',
      message: '${selectedDocuments.length} documents (${merged.pageCount} pages) were combined into one '
          'new document with its own unique ID.',
    );
  }

  Future<void> _renameSelectedDocument() async {
    final List<_RecentDocument> selectedDocuments = _selectedDocuments;
    if (selectedDocuments.length != 1) {
      return;
    }

    final _RecentDocument document = selectedDocuments.first;
    final String? updatedName = await AppSheets.textInput(
      context,
      title: 'Rename document',
      initialValue: document.title,
      hint: 'Enter new name',
    );

    if (updatedName == null || !mounted) {
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
    final String? selectedOption = await AppSheets.options(
      context,
      title: 'More actions',
      options: const [
        SheetOption(icon: Icons.photo_library_outlined, title: 'Save to photo', value: 'save_photo'),
        SheetOption(icon: Icons.picture_as_pdf_outlined, title: 'Save as PDF', value: 'save_pdf'),
      ],
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

    if (selectedOption == 'save_pdf') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saving $_selectedCount selected document(s) as PDF...')),
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
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: FadeSlideIn(child: _buildOfflineBanner()),
                    ),
                    FadeSlideIn(
                      index: 1,
                      child: Row(
                        children: [
                          Expanded(child: _statCard('245', 'Documents', Icons.description_outlined)),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard('12', 'Pending Sync', Icons.cloud_sync_outlined)),
                          const SizedBox(width: 12),
                          Expanded(child: _statCard('6', 'Shared Today', Icons.send_outlined)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SectionHeader('Quick Actions'),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      index: 2,
                      child: Row(
                        children: [
                          Expanded(
                            child: _quickAction(
                              Icons.document_scanner_rounded,
                              'Scan Document',
                              'Camera or gallery',
                              highlighted: true,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ScanCameraScreen()),
                                );
                                _loadSavedScans();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _quickAction(
                              Icons.handyman_outlined,
                              'Open Tools',
                              'Convert & export',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DocumentVaultScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      index: 2,
                      child: _quickAction(
                        Icons.verified_user_outlined,
                        'Verify Document',
                        'Check a document ID',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VerifyDocumentScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SectionHeader(
                      'Recent Documents',
                      trailing: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _hasSelectedDocuments
                            ? TextButton(
                                key: const ValueKey('cancel'),
                                onPressed: _clearSelection,
                                child: Text('Cancel ($_selectedCount)'),
                              )
                            : StatusBadge(
                                key: const ValueKey('count'),
                                label: '${_recentDocuments.length}',
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_recentDocuments.isEmpty)
                      const AppCard(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              IconTile(icon: Icons.inbox_outlined, size: 52),
                              SizedBox(height: 12),
                              Text('No recent documents', style: TextStyle(color: AppColors.textMedium)),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._recentDocuments.asMap().entries.map(
                            (entry) => FadeSlideIn(
                              index: entry.key + 3,
                              child: _documentTile(context, entry.value),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: _hasSelectedDocuments ? Offset.zero : const Offset(0, 1.5),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: SelectionActionBar(
              actions: [
                SelectionAction(Icons.share_outlined, 'Share', () => _handleBulkAction('Share')),
                SelectionAction(Icons.drive_file_move_outline, 'Move', () => _handleBulkAction('Move/Copy')),
                SelectionAction(
                  _canMerge ? Icons.merge_type_rounded : Icons.drive_file_rename_outline,
                  _canMerge ? 'Merge' : 'Rename',
                  () => _handleBulkAction(_canMerge ? 'Merge' : 'Rename'),
                ),
                SelectionAction(Icons.delete_outline_rounded, 'Delete', () => _handleBulkAction('Delete')),
                SelectionAction(Icons.more_horiz_rounded, 'More', () => _handleBulkAction('More')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 52),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: TextStyle(color: AppColors.onPrimary.withValues(alpha: 0.7), fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Yusuph J. Mwenda',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'TRA Officer',
                    style: TextStyle(color: AppColors.onPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded, size: 24, color: AppColors.onPrimary),
                ),
                Positioned(
                  right: 12,
                  top: 11,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return AppCard(
      padding: const EdgeInsets.all(14),
      shadow: AppShadows.lifted,
      child: Row(
        children: [
          const IconTile(
            icon: Icons.cloud_off_rounded,
            color: AppColors.warning,
            background: AppColors.warningSoft,
            size: 40,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are offline',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textHigh),
                ),
                SizedBox(height: 2),
                Text(
                  'Changes will sync when connection is restored.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textLow.withValues(alpha: 0.8)),
        ],
      ),
    );
  }

  Widget _statCard(String number, String label, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, size: 34),
          const SizedBox(height: 12),
          Text(
            number,
            style: const TextStyle(
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w800,
              color: AppColors.textHigh,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMedium, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(
          icon: icon,
          color: AppColors.onPrimary,
          background: highlighted ? Colors.white.withValues(alpha: 0.45) : AppColors.primarySoft,
          size: 42,
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textHigh),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: highlighted ? AppColors.onPrimary.withValues(alpha: 0.65) : AppColors.textLow,
          ),
        ),
      ],
    );

    if (!highlighted) {
      return AppCard(onTap: onTap, padding: const EdgeInsets.all(16), child: content);
    }

    // Frosted glass card: blurred backdrop with yellow fading from solid to translucent.
    final BorderRadius radius = BorderRadius.circular(20);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.95),
                      AppColors.primary.withValues(alpha: 0.55),
                      AppColors.primary.withValues(alpha: 0.18),
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _documentTile(BuildContext context, _RecentDocument document) {
    final bool isSelected = document.isSelected;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      color: isSelected ? AppColors.primaryTint : AppColors.surface,
      borderColor: isSelected ? AppColors.primary : AppColors.border,
      onTap: () => _openPreview(context, document),
      child: Row(
        children: [
          const IconTile(
            icon: Icons.picture_as_pdf_rounded,
            color: AppColors.danger,
            background: AppColors.dangerSoft,
            size: 46,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textHigh,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${document.reference} • ${document.time}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textLow, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          document.record?.isMerged ?? false
              ? const StatusBadge(label: 'MERGED', color: AppColors.success, background: AppColors.successSoft)
              : const StatusBadge(label: 'PDF'),
          Checkbox(
            value: document.isSelected,
            onChanged: (checked) {
              setState(() {
                document.isSelected = checked ?? false;
              });
              _syncSelectionMode();
            },
          ),
        ],
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
    this.record,
    this.isSelected = false,
  });

  String title;
  final String reference;
  final String time;
  final String notes;

  /// Registry entry for documents scanned in the app; null for sample documents.
  final ScannedDocumentRecord? record;
  bool isSelected;
}
