import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'recent_document_preview_screen.dart';
import 'share_document_screen.dart';

class MyScansScreen extends StatefulWidget {
  const MyScansScreen({super.key, this.onSelectionModeChanged});

  final ValueChanged<bool>? onSelectionModeChanged;

  @override
  State<MyScansScreen> createState() => _MyScansScreenState();
}

class _MyScansScreenState extends State<MyScansScreen> {
  final List<_ScanDocument> _documents = <_ScanDocument>[
    _ScanDocument(id: 1, title: 'Tax Compliance Guidelines', date: '20 May 2024', status: 'Synced'),
    _ScanDocument(id: 2, title: 'HR Circular - Leave Policy', date: '19 May 2024', status: 'Pending'),
    _ScanDocument(id: 3, title: 'Office Memorandum', date: '18 May 2024', status: 'Synced'),
    _ScanDocument(id: 4, title: 'Retirement of travel', date: '17 May 2024', status: 'Pending'),
  ];

  final Set<int> _selectedIds = <int>{};
  String _activeFilter = 'All';

  bool get _hasSelection => _selectedIds.isNotEmpty;
  bool get _canMerge => _selectedIds.length > 1;
  List<_ScanDocument> get _selectedDocuments => _documents.where((doc) => _selectedIds.contains(doc.id)).toList();

  void _notifySelectionMode() {
    widget.onSelectionModeChanged?.call(_hasSelection);
  }

  void _toggleSelection(int id, bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
    _notifySelectionMode();
  }

  Future<void> _runBulkAction(String action) async {
    if (!_hasSelection) {
      return;
    }

    if (action == 'Share') {
      _openShareForSelectedDocuments();
      return;
    }

    if (action == 'More') {
      _showMoreActions();
      return;
    }

    if (action == 'Delete') {
      final bool shouldDelete = await AppSheets.confirm(
        context,
        title: 'Delete scans?',
        message: 'Delete ${_selectedIds.length} selected scan(s)? This cannot be undone.',
      );

      if (!shouldDelete || !mounted) {
        return;
      }

      setState(() {
        _documents.removeWhere((doc) => _selectedIds.contains(doc.id));
        _selectedIds.clear();
      });
      _notifySelectionMode();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected documents deleted.')),
      );
      return;
    }

    if (action == 'Rename') {
      _renameSelectedDocument();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action for ${_selectedIds.length} selected document(s).')),
    );
  }

  Future<void> _renameSelectedDocument() async {
    final List<_ScanDocument> selectedDocs = _selectedDocuments;
    if (selectedDocs.length != 1) {
      return;
    }

    final _ScanDocument document = selectedDocs.first;
    final String? updatedName = await AppSheets.textInput(
      context,
      title: 'Rename scan',
      initialValue: document.title,
      hint: 'Scan name',
    );

    if (updatedName == null || !mounted) {
      return;
    }

    setState(() {
      document.title = updatedName;
      _selectedIds.clear();
    });
    _notifySelectionMode();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan renamed successfully.')),
    );
  }

  void _openShareForSelectedDocuments() {
    final List<_ScanDocument> selectedDocs = _selectedDocuments;
    if (selectedDocs.isEmpty) {
      return;
    }

    final _ScanDocument primary = selectedDocs.first;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShareDocumentScreen(
          title: selectedDocs.length == 1 ? primary.title : '${selectedDocs.length} selected scans',
          referenceNumber: selectedDocs.length == 1 ? 'SCAN-${primary.id}' : 'MULTI-SCAN-${selectedDocs.length}',
          notes: selectedDocs.map((doc) => '${doc.title} (${doc.date})').join('\n'),
          attachedImagePaths: selectedDocs.map((doc) => 'scan-${doc.id}').toList(),
        ),
      ),
    );
  }

  void _openPreview(_ScanDocument doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecentDocumentPreviewScreen(
          title: doc.title,
          referenceNumber: 'SCAN-${doc.id}',
          timestamp: doc.date,
          onDelete: () {
            setState(() {
              _documents.remove(doc);
              _selectedIds.remove(doc.id);
            });
            _notifySelectionMode();
          },
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
        SnackBar(content: Text('Saving ${_selectedIds.length} selected document(s) to photo gallery...')),
      );
      return;
    }

    if (selectedOption == 'save_pdf') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saving ${_selectedIds.length} selected document(s) as PDF...')),
      );
    }
  }

  List<_ScanDocument> _filteredDocuments(String filter) {
    if (filter == 'All') {
      return _documents;
    }
    return _documents.where((doc) => doc.status == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _hasSelection ? '${_selectedIds.length} selected' : 'My Scans',
            key: ValueKey<bool>(_hasSelection),
          ),
        ),
        actions: _hasSelection
            ? [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIds.clear();
                    });
                    _notifySelectionMode();
                  },
                  child: const Text('Cancel'),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: PillSegmented(
              options: const ['All', 'Pending', 'Synced'],
              icons: const [Icons.folder_open_rounded, Icons.schedule_rounded, Icons.cloud_done_outlined],
              selected: _activeFilter,
              onChanged: (value) => setState(() => _activeFilter = value),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey<String>(_activeFilter),
                child: _buildScansList(_activeFilter),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: _hasSelection
            ? SelectionActionBar(
                actions: [
                  SelectionAction(Icons.share_outlined, 'Share', () => _runBulkAction('Share')),
                  SelectionAction(Icons.drive_file_move_outline, 'Move', () => _runBulkAction('Move/Copy')),
                  SelectionAction(
                    _canMerge ? Icons.merge_type_rounded : Icons.drive_file_rename_outline,
                    _canMerge ? 'Merge' : 'Rename',
                    () => _runBulkAction(_canMerge ? 'Merge' : 'Rename'),
                  ),
                  SelectionAction(Icons.delete_outline_rounded, 'Delete', () => _runBulkAction('Delete')),
                  SelectionAction(Icons.more_horiz_rounded, 'More', () => _runBulkAction('More')),
                ],
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }

  Widget _buildScansList(String filter) {
    final List<_ScanDocument> docs = _filteredDocuments(filter);

    if (docs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTile(icon: Icons.inbox_outlined, size: 60),
            SizedBox(height: 14),
            Text(
              'No documents in this category',
              style: TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      itemCount: docs.length,
      itemBuilder: (context, index) => FadeSlideIn(index: index, child: _buildScanItem(docs[index])),
    );
  }

  Widget _buildScanItem(_ScanDocument doc) {
    final bool selected = _selectedIds.contains(doc.id);
    final bool pending = doc.status == 'Pending';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      color: selected ? AppColors.primaryTint : AppColors.surface,
      borderColor: selected ? AppColors.primary : AppColors.border,
      onTap: () => _openPreview(doc),
      child: Row(
        children: [
          IconTile(
            icon: Icons.description_outlined,
            color: pending ? AppColors.warning : AppColors.success,
            background: pending ? AppColors.warningSoft : AppColors.successSoft,
            size: 46,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textHigh),
                ),
                const SizedBox(height: 4),
                Text(
                  doc.date,
                  style: const TextStyle(color: AppColors.textLow, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(
            label: doc.status,
            color: pending ? AppColors.warning : AppColors.success,
            background: pending ? AppColors.warningSoft : AppColors.successSoft,
          ),
          Checkbox(
            value: selected,
            onChanged: (checked) => _toggleSelection(doc.id, checked),
          ),
        ],
      ),
    );
  }
}

class _ScanDocument {
  _ScanDocument({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
  });

  final int id;
  String title;
  final String date;
  final String status;
}
