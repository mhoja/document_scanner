import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'share_document_screen.dart';

class MyScansScreen extends StatefulWidget {
  const MyScansScreen({super.key, this.onSelectionModeChanged});

  final ValueChanged<bool>? onSelectionModeChanged;

  @override
  State<MyScansScreen> createState() => _MyScansScreenState();
}

class _MyScansScreenState extends State<MyScansScreen> {
  static const Color _primaryBlue = Color(0xFF1F56FF);
  static const Color _deepBlue = Color(0xFF8B6400);
  static const Color _mint = Color(0xFF16B8A6);

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
      final bool shouldDelete = await _showCompactDeleteSheet(
        title: 'Delete scans',
        message: 'Delete ${_selectedIds.length} selected scan(s)?',
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
    final String? updatedName = await _showCompactRenameSheet(
      initialName: document.title,
      heading: 'Rename scan',
      hint: 'Scan name',
    );

    if (updatedName == null || updatedName.isEmpty || !mounted) {
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
        SnackBar(content: Text('Saving ${_selectedIds.length} selected document(s) to photo gallery...')),
      );
      return;
    }

    if (selectedOption == 'print') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Printing ${_selectedIds.length} selected document(s)...')),
      );
      return;
    }

    if (selectedOption == 'download_pdf') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading ${_selectedIds.length} selected document(s) as PDF...')),
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
      backgroundColor: const Color(0xFFF3F7FF),
      appBar: AppBar(
        title: Text(
          _hasSelection ? '${_selectedIds.length} selected' : 'My Scans',
          style: const TextStyle(
            color: Color(0xFF000000),
            fontWeight: FontWeight.w700,
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
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF1A1A1A))),
                ),
              ]
            : null,
        backgroundColor: _deepBlue,
        foregroundColor: const Color(0xFF1A1A1A),
        titleTextStyle: const TextStyle(
          color: Color(0xFF000000),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        toolbarTextStyle: const TextStyle(color: Color(0xFF000000)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFB800), Color(0xFFE3A100)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF1FF), Color(0xFFF7FAFF), Color(0xFFFFFFFF)],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFFFF9E8)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF0E1B2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.95),
                    blurRadius: 12,
                    offset: const Offset(-1, -1),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFB800).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    _filterChipButton('All'),
                    const SizedBox(width: 8),
                    _filterChipButton('Pending'),
                    const SizedBox(width: 8),
                    _filterChipButton('Synced'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _buildScansList(_activeFilter),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _hasSelection
          ? SafeArea(
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
                    _bottomAction(Icons.share_outlined, 'Share', () => _runBulkAction('Share')),
                    _bottomAction(Icons.drive_file_move_outline, 'Move/Copy', () => _runBulkAction('Move/Copy')),
                    _bottomAction(
                      _canMerge ? Icons.merge_type : Icons.drive_file_rename_outline,
                      _canMerge ? 'Merge' : 'Rename',
                      () => _runBulkAction(_canMerge ? 'Merge' : 'Rename'),
                    ),
                    _bottomAction(Icons.delete_outline, 'Delete', () => _runBulkAction('Delete')),
                    _bottomAction(Icons.more_horiz, 'More', () => _runBulkAction('More')),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildScansList(String filter) {
    final List<_ScanDocument> docs = _filteredDocuments(filter);

    if (docs.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDCE5F8)),
          ),
          child: const Text(
            'No documents in this category.',
            style: TextStyle(color: Color(0xFF60759E), fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: docs.map(_buildScanItem).toList(),
    );
  }

  Widget _filterChipButton(String label) {
    final bool selected = _activeFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeFilter = label;
          });
        },
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(22),
          strokeWidth: 1.1,
          dashPattern: const [3, 3],
          color: selected ? const Color(0xFFFFE49A) : const Color(0xFFF0DB9C),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFC21F), Color(0xFFFFB000)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFAEB), Color(0xFFFFF2CC)],
                    ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFF1A1A1A) : const Color(0xFF745500),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanItem(_ScanDocument doc) {
    final bool selected = _selectedIds.contains(doc.id);
    final bool pending = doc.status == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: selected
              ? const [Color(0xFFE9F7FF), Color(0xFFF2FBFF)]
              : const [Color(0xFFFFFFFF), Color(0xFFF6F9FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? const Color(0xFF95C5FF) : const Color(0xFFDCE5F8),
          width: selected ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            blurRadius: 14,
            offset: const Offset(-1, -1),
          ),
          BoxShadow(
            color: (selected ? _primaryBlue : _mint).withValues(alpha: 0.09),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: pending
                    ? const [Color(0xFFFFF4E8), Color(0xFFFFEBD8)]
                    : const [Color(0xFFE8F5EE), Color(0xFFDDF3E9)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_outlined,
              color: pending ? const Color(0xFFD58B18) : const Color(0xFF148C7A),
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172E64),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  doc.date,
                  style: const TextStyle(
                    color: Color(0xFF647CA7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: pending
                    ? const [Color(0xFFFFF3DF), Color(0xFFFFE7C5)]
                    : const [Color(0xFFE4F9EE), Color(0xFFD5F3E5)],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              doc.status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: pending ? const Color(0xFFB9710C) : const Color(0xFF11745E),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Checkbox(
            value: selected,
            onChanged: (checked) => _toggleSelection(doc.id, checked),
            activeColor: _primaryBlue,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            side: BorderSide(color: selected ? _primaryBlue : const Color(0xFFB4C6EA), width: 1.4),
          ),
        ],
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