import 'package:flutter/material.dart';
import 'scan_preview_screen.dart';

class ScanCameraScreen extends StatefulWidget {
  const ScanCameraScreen({super.key});

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> {
  @override
  Widget build(BuildContext context) {
    final navy = const Color(0xFF003E7E);
    final yellow = const Color(0xFFFFB400);

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        title: const Text("Scan Document", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview Area (framing guide)
          Container(
            color: Colors.black,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                width: double.infinity,
                height: 520,
                decoration: BoxDecoration(
                  border: Border.all(color: yellow, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Position document within the frame",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Single / Multi toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text("Single Page", style: TextStyle(color: Colors.white)),
                      ),
                      VerticalDivider(color: Colors.white24, width: 1, thickness: 1),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text("Multi Page", style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gallery / Thumbnail
                    IconButton(
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                      onPressed: () {},
                    ),

                    // Capture Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScanPreviewScreen()),
                        );
                      },
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: yellow,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 18, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.camera, size: 40, color: Colors.white),
                        ),
                      ),
                    ),

                    // Auto / Settings
                    TextButton(
                      onPressed: () {},
                      child: const Text('Auto', style: TextStyle(color: Colors.white70)),
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
}