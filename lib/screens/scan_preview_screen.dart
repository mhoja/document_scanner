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
  static const Color _primaryBlue = Color(0xFF1B4DFF);
  static const Color _deepBlue = Color(0xFF0E2A7A);
  static const Color _accentCyan = Color(0xFF35C5FF);
  static const Color _surface = Color(0xFFFFFFFF);

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
      backgroundColor: const Color(0xFFEFF4FF),
      appBar: AppBar(
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B2B80), Color(0xFF1E5FFF)],
            ),
          ),
        ),
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
              style: TextStyle(color: Color(0xFFFFE38A), fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFE9F1FF),
                const Color(0xFFF6F9FF),
                Colors.white,
              ],
            ),
          ),
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFFFFF),
                        const Color(0xFFF1F5FF).withValues(alpha: 0.95),
                        const Color(0xFFEFFBFF).withValues(alpha: 0.88),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD7E2FF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.95),
                        blurRadius: 20,
                        offset: const Offset(-1, -1),
                      ),
                      BoxShadow(
                        color: const Color(0xFF1B4DFF).withValues(alpha: 0.09),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildToolButton(Icons.rotate_left, 'Rotate', () {}),
                        const SizedBox(width: 20),
                        _buildToolButton(Icons.crop, 'Crop', () {}),
                        const SizedBox(width: 20),
                        _buildToolButton(Icons.filter_tilt_shift, 'Filter', () {}),
                        const SizedBox(width: 20),
                        _buildToolButton(Icons.delete_outline, 'Delete', _deleteCurrentPage),
                        const SizedBox(width: 20),
                        _buildToolButton(Icons.tune, 'Reorder', () {}),
                      ],
                    ),
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
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFC9D8FF)),
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
                                style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1342CE)),
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
                          elevation: 0,
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    selected ? const Color(0xFFEAFDFF) : const Color(0xFFFFFFFF),
                    selected
                        ? const Color(0xFFDDF4FF)
                        : const Color(0xFFF2F4FF),
                    selected
                        ? const Color(0xFFEDE8FF)
                        : const Color(0xFFEFF8FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? _accentCyan : const Color(0xFFD5DFF5),
                  width: selected ? 2.2 : 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.95),
                    blurRadius: 18,
                    offset: const Offset(-1, -1),
                  ),
                  BoxShadow(
                    color: (selected ? _accentCyan : _primaryBlue).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF194AF4), Color(0xFF31BFFF)],
              ),
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF2F7FF),
                    const Color(0xFFE7FAFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFBFD1FF),
                  width: 1.6,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.95),
                    blurRadius: 18,
                    offset: const Offset(-1, -1),
                  ),
                  BoxShadow(
                    color: _primaryBlue.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: _isAddingMore
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Icon(Icons.add, size: 42, color: Color(0xFF194AF4)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add Page',
            style: TextStyle(color: Color(0xFF31509B), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEDF3FF), Color(0xFFDCE8FF)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC9D8FF)),
            ),
            child: Icon(icon, color: _deepBlue, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFF173A8C), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}