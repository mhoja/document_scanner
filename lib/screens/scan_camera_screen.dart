// import 'package:flutter/material.dart';
// import 'scan_preview_screen.dart';

// class ScanCameraScreen extends StatelessWidget {
//   const ScanCameraScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text("Scan Document", style: TextStyle(color: Colors.white)),
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Stack(
//         children: [
//           const Center(
//             child: Text(
//               "Camera Preview\nPosition document within the frame",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white70, fontSize: 18),
//             ),
//           ),
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => const ScanPreviewScreen()),
//                   );
//                 },
//                 child: Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.yellow, width: 4),
//                   ),
//                   child: const Icon(Icons.camera, size: 40, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';

import 'scan_preview_screen.dart';

class ScanCameraScreen extends StatefulWidget {
  const ScanCameraScreen({super.key});

  @override
  State<ScanCameraScreen> createState() => _ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> {
  bool _isMultiPage = true;
  bool _isScanning = false;

  Future<void> _startScan() async {
    if (_isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      final List<String>? images = await CunningDocumentScanner.getPictures(
        noOfPages: _isMultiPage ? 20 : 1,
        isGalleryImportAllowed: true,
      );

      if (!mounted) {
        return;
      }

      if (images != null && images.isNotEmpty) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanPreviewScreen(scannedImagePaths: images),
          ),
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan document. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.brown.shade900,
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      ),
                      const Icon(Icons.flash_on, color: Colors.white, size: 28),
                      const Icon(Icons.settings, color: Colors.white, size: 28),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Align document within the frame',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const Positioned(top: 18, left: 20, child: _FrameCorner(top: true, left: true)),
                        const Positioned(top: 18, right: 20, child: _FrameCorner(top: true, left: false)),
                        const Positioned(bottom: 18, left: 20, child: _FrameCorner(top: false, left: true)),
                        const Positioned(bottom: 18, right: 20, child: _FrameCorner(top: false, left: false)),
                        Positioned(
                          bottom: 26,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'Align document within the frame',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionCircle(Icons.photo_library_outlined, label: 'Gallery', onTap: _startScan),
                      GestureDetector(
                        onTap: _startScan,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _isScanning ? 36 : 72,
                              height: _isScanning ? 36 : 72,
                              decoration: BoxDecoration(
                                color: _isScanning ? Colors.redAccent : Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _actionCircle(
                        Icons.burst_mode,
                        label: _isMultiPage ? 'Multi' : 'Single',
                        onTap: () {
                          setState(() {
                            _isMultiPage = !_isMultiPage;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _modeButton(
                            label: 'Single Page',
                            selected: !_isMultiPage,
                            onTap: () => setState(() => _isMultiPage = false),
                          ),
                        ),
                        Expanded(
                          child: _modeButton(
                            label: 'Multi Page',
                            selected: _isMultiPage,
                            onTap: () => setState(() => _isMultiPage = true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            if (_isScanning)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionCircle(IconData icon, {required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _modeButton({required String label, required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _FrameCorner extends StatelessWidget {
  const _FrameCorner({required this.top, required this.left});

  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: CustomPaint(
        painter: _FrameCornerPainter(top: top, left: left),
      ),
    );
  }
}

class _FrameCornerPainter extends CustomPainter {
  _FrameCornerPainter({required this.top, required this.left});

  final bool top;
  final bool left;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFF5B027)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();

    final double x = left ? 0 : size.width;
    final double y = top ? 0 : size.height;
    final double h = left ? size.width : -size.width;
    final double v = top ? size.height : -size.height;

    path.moveTo(x, y + v * 0.7);
    path.lineTo(x, y);
    path.lineTo(x + h * 0.7, y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FrameCornerPainter oldDelegate) {
    return oldDelegate.top != top || oldDelegate.left != left;
  }
}