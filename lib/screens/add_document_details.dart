import 'package:flutter/material.dart';

import '../services/document_registry.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/document_id_card.dart';
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

  /// Set once the scan has been issued its unique ID; reused for later actions
  /// so one scan never ends up with two IDs.
  ScannedDocumentRecord? _record;
  bool _isIssuing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAttachment = widget.attachedImagePaths.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("Document Details")),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                children: [
                  FadeSlideIn(
                    child: AppCard(
                      color: hasAttachment ? AppColors.primaryTint : AppColors.dangerSoft,
                      borderColor: hasAttachment ? AppColors.primarySoft : AppColors.dangerSoft,
                      shadow: const [],
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          IconTile(
                            icon: hasAttachment ? Icons.description_outlined : Icons.error_outline_rounded,
                            color: hasAttachment ? AppColors.primaryDark : AppColors.danger,
                            background: hasAttachment ? AppColors.primarySoft : Colors.white,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hasAttachment
                                  ? '${widget.attachedImagePaths.length} page(s) attached'
                                  : 'No document attached',
                              style: TextStyle(
                                color: hasAttachment ? AppColors.textHigh : AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeSlideIn(
                    index: 1,
                    child: _field(
                      label: "Document Title",
                      required: true,
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.title_rounded)),
                      ),
                    ),
                  ),
                  FadeSlideIn(
                    index: 2,
                    child: _field(
                      label: "Reference Number",
                      child: TextField(
                        controller: _refController,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.tag_rounded)),
                      ),
                    ),
                  ),
                  FadeSlideIn(
                    index: 3,
                    child: _field(
                      label: "Notes",
                      child: TextField(
                        controller: _notesController,
                        maxLines: 5,
                        decoration: const InputDecoration(hintText: "Add any notes about this document"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: hasAttachment && !_isIssuing ? _save : null,
                    icon: _isIssuing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.onPrimary),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_record == null ? "Save & Issue ID" : "View Document ID"),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: hasAttachment && !_isIssuing ? _share : null,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text('Share Within TRA'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _referenceNumber => _refController.text.trim().isEmpty ? 'N/A' : _refController.text.trim();

  Future<ScannedDocumentRecord?> _issueId() async {
    if (_record != null) return _record;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a document title.')));
      return null;
    }

    setState(() => _isIssuing = true);
    try {
      final record = await DocumentRegistry.instance.register(
        pagePaths: widget.attachedImagePaths,
        title: _titleController.text.trim(),
        referenceNumber: _referenceNumber,
        notes: _notesController.text.trim(),
      );
      if (mounted) setState(() => _record = record);
      return record;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not issue a document ID. Please try again.')),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isIssuing = false);
    }
  }

  Future<void> _save() async {
    final record = await _issueId();
    if (record == null || !mounted) return;

    await showDocumentIdSheet(
      context,
      record,
      title: 'Document Saved Successfully!',
      message: 'This scan has a unique ID. Anyone at TRA can check it with Verify Document.',
    );
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _share() async {
    final record = await _issueId();
    if (record == null || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShareDocumentScreen(
          title: record.title,
          referenceNumber: record.referenceNumber,
          notes: record.notes,
          attachedImagePaths: widget.attachedImagePaths,
          record: record,
        ),
      ),
    );
  }

  Widget _field({required String label, required Widget child, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              children: [
                TextSpan(
                  text: required ? ' *' : '  (optional)',
                  style: TextStyle(
                    color: required ? AppColors.danger : AppColors.textLow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textHigh),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
