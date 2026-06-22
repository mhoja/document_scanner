import 'package:flutter/material.dart';

class MyScansScreen extends StatefulWidget {
  const MyScansScreen({super.key});

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

  bool get _hasSelection => _selectedIds.isNotEmpty;

  void _toggleSelection(int id, bool? checked) {
    setState(() {
      if (checked == true) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
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
      appBar: AppBar(
        title: Text(_hasSelection ? '${_selectedIds.length} selected' : 'My Scans'),
        actions: _hasSelection
            ? [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIds.clear();
                    });
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
              ]
            : null,
        backgroundColor: const Color(0xFF003087),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: "All"),
                Tab(text: "Pending"),
                Tab(text: "Synced"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildScansList("All"),
                  _buildScansList("Pending"),
                  _buildScansList("Synced"),
                ],
              ),
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
                    _bottomAction(Icons.drive_file_rename_outline, 'Rename', () => _runBulkAction('Rename')),
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
      return const Center(
        child: Text('No documents in this category.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: docs.map(_buildScanItem).toList(),
    );
  }

  Widget _buildScanItem(_ScanDocument doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.blue, size: 40),
        title: Text(
          doc.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Expanded(child: Text(doc.date)),
            Chip(
              label: Text(doc.status),
              visualDensity: VisualDensity.compact,
              backgroundColor: doc.status == 'Pending' ? Colors.orange[100] : Colors.green[100],
            ),
          ],
        ),
        trailing: Checkbox(
          value: _selectedIds.contains(doc.id),
          onChanged: (checked) => _toggleSelection(doc.id, checked),
          activeColor: const Color(0xFF00BFA5),
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