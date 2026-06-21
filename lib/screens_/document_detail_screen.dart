import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'scan_preview_screen.dart';

class DocumentDetailScreen extends StatefulWidget {
  final String title;
  final String date;
  final String status;
  final String referenceNumber;
  final String notes;
  final String scannedBy;

  const DocumentDetailScreen({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    required this.referenceNumber,
    required this.notes,
    required this.scannedBy,
  });

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  final List<String> _pages = ['Page 1', 'Page 2', 'Page 3'];
  int _selectedPageIndex = 0;

  void _addPage(String source) {
    setState(() {
      _pages.add('Page ${_pages.length + 1}');
      _selectedPageIndex = _pages.length - 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added a new page from $source.')),
    );
  }

  void _removePage(int index) {
    if (_pages.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A document must keep at least one page.')),
      );
      return;
    }

    final removedPage = _pages[index];
    setState(() {
      _pages.removeAt(index);
      if (_selectedPageIndex >= _pages.length) {
        _selectedPageIndex = _pages.length - 1;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$removedPage removed.')),
    );
  }

  void _showAddPageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Page', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Choose how to add a new page to this document.'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF003E7E)),
                  title: const Text('Scan new page'),
                  onTap: () {
                    Navigator.pop(context);
                    _addPage('camera');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo, color: Color(0xFF003E7E)),
                  title: const Text('Add from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _addPage('gallery');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRemovePageDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove page', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Do you want to remove ${_pages[index]} from this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB8472F)),
            onPressed: () {
              Navigator.pop(context);
              _removePage(index);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTile(int index) {
    final bool isSelected = index == _selectedPageIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPageIndex = index;
        });
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF003E7E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF003E7E) : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pages[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap to view',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 6,
              top: 6,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showRemovePageDialog(index),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white24 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: isSelected ? Colors.white : Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navy = const Color(0xFF003E7E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Detail', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8472F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text('PDF • 245 KB', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Pages Section
              const Text('Pages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Page preview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              TextButton.icon(
                                onPressed: () => _showAddPageOptions(context),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add page'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Center(
                              child: Text(
                                '${_pages[_selectedPageIndex]} preview',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 88,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _pages.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) => _buildPageTile(index),
                              padding: const EdgeInsets.only(bottom: 4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Document Details Section
              const Text('Document Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Document Title', widget.title),
                    const SizedBox(height: 12),
                    _buildDetailRow('Reference Number', widget.referenceNumber),
                    const SizedBox(height: 12),
                    _buildDetailRow('Notes', widget.notes),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Actions Section with Circular Buttons
              const Text('Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 68,
                    child: _buildActionButton(
                      icon: Icons.camera_alt,
                      label: 'View',
                      color: const Color(0xFF003E7E),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScanPreviewScreen()),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 68,
                    child: _buildActionButton(
                      icon: Icons.email,
                      label: 'Outlook',
                      color: Colors.blue.shade700,
                      onPressed: () => _openOutlook(context),
                    ),
                  ),
                  SizedBox(
                    width: 68,
                    child: _buildActionButton(
                      icon: Icons.language,
                      label: 'TRA Mail',
                      color: Colors.indigo.shade700,
                      onPressed: () => _openTraMail(context),
                    ),
                  ),
                  SizedBox(
                    width: 68,
                    child: _buildActionButton(
                      icon: Icons.download,
                      label: 'Download',
                      color: Colors.green.shade600,
                      onPressed: () => _downloadDocument(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Audit Log Section
              const Text('Audit Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAuditRow('Scanned by', widget.scannedBy),
                    const SizedBox(height: 12),
                    _buildAuditRow('Date & Time', widget.date),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAuditRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> _openOutlook(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': 'Document: ${widget.title}',
        'body': 'Please review the document "${widget.title}" with reference number ${widget.referenceNumber} dated ${widget.date}.\n\nNotes:\n${widget.notes}',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open email client. Please install Outlook or set an email client.')),
      );
    }
  }

  void _downloadDocument(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download started...')),
    );
  }

  Future<void> _openTraMail(BuildContext context) async {
    final body = Uri.encodeComponent('Please review the attached document "${widget.title}" with reference number ${widget.referenceNumber} dated ${widget.date}.\n\nNotes:\n${widget.notes}');
    final subject = Uri.encodeComponent('Document: ${widget.title}');
    final url = 'https://mail.tra.go.tz/owa/#path=/mail/action/compose&subject=$subject&body=$body';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await _openTraMailLoginFallback(context);
      }
    } else {
      await _openTraMailLoginFallback(context);
    }
  }

  Future<void> _openTraMailLoginFallback(BuildContext context) async {
    final loginUri = Uri.parse('https://mail.tra.go.tz/owa/');
    if (await canLaunchUrl(loginUri)) {
      await launchUrl(loginUri, mode: LaunchMode.externalApplication);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to TRA Mail. Compose will open after login if supported by the browser.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open TRA Mail. Please check your browser or network.')),
      );
    }
  }
}
