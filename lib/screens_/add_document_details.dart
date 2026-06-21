import 'package:flutter/material.dart';

class AddDocumentDetailsScreen extends StatefulWidget {
  const AddDocumentDetailsScreen({super.key});

  @override
  State<AddDocumentDetailsScreen> createState() => _AddDocumentDetailsScreenState();
}

class _AddDocumentDetailsScreenState extends State<AddDocumentDetailsScreen> {
  final _titleController = TextEditingController();
  final _refController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final navy = const Color(0xFF003E7E);
    final yellow = const Color(0xFFFFB400);

    return Scaffold(
      appBar: AppBar(title: const Text("Document Details"), backgroundColor: navy),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Document Title *",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _refController,
              decoration: InputDecoration(
                labelText: "Reference Number (Optional)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Notes (Optional)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Spacer(),
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
                style: ElevatedButton.styleFrom(backgroundColor: yellow, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Save", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}