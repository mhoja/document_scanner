import 'package:flutter/material.dart';

import 'share_document_screen.dart';

class AddDocumentDetailsScreen extends StatefulWidget {
  const AddDocumentDetailsScreen({this.attachedImagePaths = const <String>[], super.key});

  final List<String> attachedImagePaths;

  @override
  State<AddDocumentDetailsScreen> createState() => _AddDocumentDetailsScreenState();
}

class _AddDocumentDetailsScreenState extends State<AddDocumentDetailsScreen> {
  final _titleController = TextEditingController(text: "Office Memorandum on Timings");
  final _refController = TextEditingController(text: "TRADM/2024/045");
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool hasAttachment = widget.attachedImagePaths.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Details"),
        backgroundColor: const Color(0xFF003087),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Document Title *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const Text("Reference Number (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _refController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const Text("Notes (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Add any notes about this document",
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    hasAttachment ? Icons.attach_file : Icons.error_outline,
                    color: hasAttachment ? Colors.green : Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasAttachment
                        ? '${widget.attachedImagePaths.length} page(s) attached'
                        : 'No document attached',
                    style: TextStyle(
                      color: hasAttachment ? Colors.green.shade700 : Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Document Saved Successfully!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF228B22),
                  ),
                  child: const Text("Save", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: hasAttachment
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShareDocumentScreen(
                                title: _titleController.text.trim(),
                                referenceNumber: _refController.text.trim().isEmpty
                                    ? 'N/A'
                                    : _refController.text.trim(),
                                notes: _notesController.text.trim(),
                                attachedImagePaths: widget.attachedImagePaths,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF003087), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Share Within TRA',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF003087),
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
}