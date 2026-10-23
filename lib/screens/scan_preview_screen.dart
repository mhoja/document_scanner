import 'package:flutter/material.dart';

import '../services/page_source.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'add_document_details.dart';

class ScanPreviewScreen extends StatefulWidget {
  const ScanPreviewScreen({required this.scannedImagePaths, super.key});

  final List<String> scannedImagePaths;

  @override
  State<ScanPreviewScreen> createState() => _ScanPreviewScreenState();
}

class _ScanPreviewScreenState extends State<ScanPreviewScreen> {
  late List<String> _pages;
  int _selectedPageIndex = 0;
  bool _isAddingMore = false;

  @override
  void initState() {
    super.initState();
    _pages = List<String>.from(widget.scannedImagePaths);
  }

  void _deleteCurrentPage() {
    if (_pages.isEmpty) {
      return;
    }

    setState(() {
      _pages.removeAt(_selectedPageIndex);

      if (_selectedPageIndex >= _pages.length && _pages.isNotEmpty) {
        _selectedPageIndex = _pages.length - 1;
      }
    });

    if (_pages.isEmpty && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _addMorePages() async {
    if (_isAddingMore) {
      return;
    }

    setState(() {
      _isAddingMore = true;
    });

    try {
      final List<String>? morePages = await PageSource.capture(maxPages: 20);

      if (!mounted) {
        return;
      }

      if (morePages != null && morePages.isNotEmpty) {
        setState(() {
          _pages.addAll(morePages);
          _selectedPageIndex = _pages.length - morePages.length;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add pages right now. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingMore = false;
        });
      }
    }
  }

  void _openDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDocumentDetailsScreen(attachedImagePaths: _pages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPages = _pages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Pages'),
        actions: [
          TextButton(
            onPressed: hasPages ? _openDetails : null,
            child: const Text('Save', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_pages.length} page${_pages.length == 1 ? '' : 's'} scanned',
                style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  itemCount: _pages.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    if (index == _pages.length) {
                      return FadeSlideIn(index: index, child: _buildAddPageTile());
                    }

                    return FadeSlideIn(
                      index: index,
                      child: _buildPageTile(index: index, selected: index == _selectedPageIndex),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Row(
                  children: [
                    _buildToolButton(Icons.rotate_left_rounded, 'Rotate', () {}),
                    _buildToolButton(Icons.crop_rounded, 'Crop', () {}),
                    _buildToolButton(Icons.auto_fix_high_rounded, 'Filter', () {}),
                    _buildToolButton(Icons.delete_outline_rounded, 'Delete', _deleteCurrentPage, danger: true),
                    _buildToolButton(Icons.swap_vert_rounded, 'Reorder', () {}),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAddingMore ? null : _addMorePages,
                      icon: _isAddingMore
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded),
                      label: const Text('Add More'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: hasPages ? _openDetails : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageTile({required int index, required bool selected}) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPageIndex = index),
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 2.4 : 1.2,
                ),
                boxShadow: selected ? AppShadows.glow(AppColors.primary) : AppShadows.soft,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageSource.image(
                  _pages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) {
                    return const ColoredBox(
                      color: AppColors.surfaceMuted,
                      child: Center(
                        child: Icon(Icons.broken_image_outlined, color: AppColors.textLow),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: selected ? AppColors.onPrimary : AppColors.textMedium,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPageTile() {
    return GestureDetector(
      onTap: _isAddingMore ? null : _addMorePages,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primarySoft, width: 1.6),
              ),
              child: Center(
                child: _isAddingMore
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.add_rounded, size: 26, color: AppColors.onPrimary),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            height: 26,
            child: Center(
              child: Text(
                'Add Page',
                style: TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTile(
                icon: icon,
                size: 38,
                color: danger ? AppColors.danger : AppColors.onPrimary,
                background: danger ? AppColors.dangerSoft : AppColors.primarySoft,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: const TextStyle(color: AppColors.textMedium, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
