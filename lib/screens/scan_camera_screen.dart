import 'package:flutter/material.dart';

import '../services/page_source.dart';
import '../theme/app_theme.dart';
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
      final List<String>? images = await PageSource.capture(maxPages: _isMultiPage ? 20 : 1);

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
                      Color(0xFF121212),
                      Color(0xFF1E1B16),
                      Color(0xFF0E0E0E),
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
                      _topButton(Icons.close_rounded, () => Navigator.maybePop(context)),
                      _topButton(Icons.flash_on_rounded, () {}),
                      _topButton(Icons.tune_rounded, () {}),
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
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.document_scanner_outlined,
                              size: 72,
                              color: Colors.white.withValues(alpha: 0.18),
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
                            border: Border.all(color: AppColors.primary, width: 4),
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              width: _isScanning ? 36 : 70,
                              height: _isScanning ? 36 : 70,
                              decoration: BoxDecoration(
                                color: _isScanning ? AppColors.primary : Colors.white,
                                borderRadius: BorderRadius.circular(_isScanning ? 10 : 35),
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

  Widget _topButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 24),
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
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.onPrimary : Colors.white,
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
      ..color = AppColors.primary
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
