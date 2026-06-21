import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';

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
      final List<String>? morePages = await CunningDocumentScanner.getPictures(
        noOfPages: 20,
        isGalleryImportAllowed: true,
      );

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

  @override
  Widget build(BuildContext context) {
    final bool hasPages = _pages.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF022A78),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Review Pages', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: hasPages
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddDocumentDetailsScreen(attachedImagePaths: _pages),
                      ),
                    );
                  }
                : null,
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFFFD43B), fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  itemCount: _pages.length + 1,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    if (index == _pages.length) {
                      return _buildAddPageTile();
                    }

                    final bool selected = index == _selectedPageIndex;
                    return _buildPageTile(index: index, selected: selected);
                  },
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildToolButton(Icons.rotate_left, 'Rotate', () {}),
                    _buildToolButton(Icons.crop, 'Crop', () {}),
                    _buildToolButton(Icons.filter_tilt_shift, 'Filter', () {}),
                    _buildToolButton(Icons.delete_outline, 'Delete', _deleteCurrentPage),
                    _buildToolButton(Icons.tune, 'Reorder', () {}),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isAddingMore ? null : _addMorePages,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: Color(0xFFD2D8E4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isAddingMore
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Add More',
                              style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0C2D7A)),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: hasPages
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddDocumentDetailsScreen(attachedImagePaths: _pages),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: const Color(0xFFFFCD00),
                        foregroundColor: const Color(0xFF102563),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Next', style: TextStyle(fontWeight: FontWeight.w800)),
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _selectedPageIndex = index),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? const Color(0xFFFFCD00) : const Color(0xFFD5DBE8),
                  width: selected ? 2.2 : 1.1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_pages[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Center(
                      child: Icon(Icons.broken_image_outlined, color: Colors.black38),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF032C7B),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPageTile() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _isAddingMore ? null : _addMorePages,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFB7C3DA),
                  width: 1.6,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: _isAddingMore
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(Icons.add, size: 42, color: Color(0xFF0D2F7E)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add Page',
            style: TextStyle(color: Color(0xFF4C5C7A), fontWeight: FontWeight.w600),
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
          Icon(icon, color: const Color(0xFF102563), size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF102563), fontSize: 12)),
        ],
      ),
    );
  }
}