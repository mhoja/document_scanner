import 'package:flutter/material.dart';

import 'share_document_screen.dart';

class RecentDocumentPreviewScreen extends StatelessWidget {
  const RecentDocumentPreviewScreen({
    required this.title,
    required this.referenceNumber,
    required this.timestamp,
    this.notes = '',
    this.onDelete,
    super.key,
  });

  final String title;
  final String referenceNumber;
  final String timestamp;
  final String notes;
  final VoidCallback? onDelete;

  Future<void> _deleteDocument(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('This will remove the document from your recent list.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (shouldDelete == true) {
      onDelete?.call();
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted from recent documents.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Document Preview'),
        backgroundColor: const Color(0xFF003087),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _deleteDocument(context),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete document',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD9E1EF)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFE6ECF6))),
                        ),
                        child: const Text(
                          'Preview',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0A235A)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 240,
                            height: 340,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFBFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFD7DEEA)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TANZANIA REVENUE AUTHORITY',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Text('Reference: $referenceNumber'),
                                  const SizedBox(height: 4),
                                  Text('Captured: $timestamp'),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Document is available for internal TRA sharing.',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.attach_file, color: Color(0xFF0C4A9A)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '1 document attachment available',
                        style: TextStyle(color: Color(0xFF0C4A9A), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShareDocumentScreen(
                          title: title,
                          referenceNumber: referenceNumber,
                          notes: notes,
                          attachedImagePaths: const <String>['recent-doc-attachment'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCD00),
                    foregroundColor: const Color(0xFF102563),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Share To TRA Staff', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
