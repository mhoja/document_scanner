import 'package:flutter/material.dart';
import 'add_document_details.dart';

class ScanPreviewScreen extends StatelessWidget {
  const ScanPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navy = const Color(0xFF003E7E);
    final yellow = const Color(0xFFFFB400);

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        title: const Text("Preview", style: TextStyle(color: Colors.white)),

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: yellow,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDocumentDetailsScreen()),
                );
              },
              child: const Text("Done", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Document Preview Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: yellow, width: 3),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.document_scanner, size: 120, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      "Document Preview",
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Toolbar with tools and actions
          Container(
            color: navy,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToolButton(Icons.rotate_left, "Rotate", () {}),
                    _buildToolButton(Icons.crop, "Crop", () {}),
                    _buildToolButton(Icons.auto_fix_high, "Enhance", () {}),
                    _buildToolButton(Icons.filter, "Filter", () {}),
                    _buildToolButton(Icons.delete, "Delete", () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellow,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddDocumentDetailsScreen()),
                          );
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}