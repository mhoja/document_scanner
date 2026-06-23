import 'package:flutter/material.dart';

class MyScansScreen extends StatefulWidget {
  const MyScansScreen({super.key, this.onSelectionModeChanged});

  final ValueChanged<bool>? onSelectionModeChanged;

  @override
  State<MyScansScreen> createState() => _MyScansScreenState();
}

class _MyScansScreenState extends State<MyScansScreen> {
  static const Color _primaryBlue = Color(0xFF1F56FF);
  static const Color _deepBlue = Color(0xFF0C2D7A);
  static const Color _mint = Color(0xFF16B8A6);

  final List<_ScanDocument> _documents = <_ScanDocument>[
    _ScanDocument(id: 1, title: 'Tax Compliance Guidelines', date: '20 May 2024', status: 'Synced'),
    _ScanDocument(id: 2, title: 'HR Circular - Leave Policy', date: '19 May 2024', status: 'Pending'),
    _ScanDocument(id: 3, title: 'Office Memorandum', date: '18 May 2024', status: 'Synced'),
    _ScanDocument(id: 4, title: 'Retirement of travel', date: '17 May 2024', status: 'Pending'),
  ];

  final Set<int> _selectedIds = <int>{};

  bool get _hasSelection => _selectedIds.isNotEmpty;
  bool get _canMerge => _selectedIds.length > 1;

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

  void _runBulkAction(String action) {
    if (!_hasSelection) {
      return;
    }

    if (action == 'More') {
      _showMoreActions();
      return;
    }

    if (action == 'Delete') {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action for ${_selectedIds.length} selected document(s).')),
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
        title: Text(_hasSelection ? '${_selectedIds.length} selected' : 'My Scans'),
        actions: _hasSelection
            ? [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIds.clear();
                    });
                    _notifySelectionMode();
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
              ]
            : null,
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A2A76), Color(0xFF2A63FF)],
            ),
          ),
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: Container(
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
                    colors: [Color(0xFFFFFFFF), Color(0xFFF2F6FF)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD8E2F8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.95),
                      blurRadius: 12,
                      offset: const Offset(-1, -1),
                    ),
                    BoxShadow(
                      color: _primaryBlue.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1846DA), Color(0xFF2B64FF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF576A95),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Pending'),
                    Tab(text: 'Synced'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildScansList('All'),
                    _buildScansList('Pending'),
                    _buildScansList('Synced'),
                  ],
                ),
              ),
            ],
          ),
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
  final String title;
  final String date;
  final String status;
}