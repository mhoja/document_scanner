import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'share_document_screen.dart';

class RecentDocumentPreviewScreen extends StatelessWidget {
  const RecentDocumentPreviewScreen({
    required this.title,
    required this.referenceNumber,
    required this.timestamp,
    this.notes = '',
    this.onDelete,
    super.key,
  });

  final String title;
  final String referenceNumber;
  final String timestamp;
  final String notes;
  final VoidCallback? onDelete;

  Future<void> _deleteDocument(BuildContext context) async {
    final bool shouldDelete = await AppSheets.confirm(
      context,
      title: 'Delete document?',
      message: 'This will remove "$title" from your recent list.',
    );

    if (shouldDelete) {
      onDelete?.call();
      if (!context.mounted) {
        return;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted from recent documents.')),
      );
    }
  }

  void _share(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShareDocumentScreen(
          title: title,
          referenceNumber: referenceNumber,
          notes: notes,
          attachedImagePaths: const <String>['recent-doc-attachment'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Preview'),
        actions: [
          IconButton(
            onPressed: () => _deleteDocument(context),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete document',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                children: [
                  FadeSlideIn(child: _buildPaper()),
                  const SizedBox(height: 20),
                  FadeSlideIn(index: 1, child: _buildDetails()),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    index: 2,
                    child: const AppCard(
                      color: AppColors.primaryTint,
                      borderColor: AppColors.primarySoft,
                      shadow: [],
                      padding: EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file_rounded, color: AppColors.primaryDark),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '1 document attachment available',
                              style: TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ElevatedButton.icon(
                onPressed: () => _share(context),
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text('Share To TRA Staff'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Container(
          width: 230,
          height: 310,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppShadows.lifted,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 6, height: 26, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'TANZANIA REVENUE AUTHORITY',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textHigh),
              ),
              const SizedBox(height: 14),
              ...List.generate(6, (i) => _paperLine(i == 5 ? 0.6 : 1)),
              const Spacer(),
              Text(
                referenceNumber,
                style: const TextStyle(fontSize: 10, color: AppColors.textLow, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paperLine(double widthFactor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textHigh),
          ),
          const SizedBox(height: 14),
          _detailRow(Icons.tag_rounded, 'Reference', referenceNumber),
          _detailRow(Icons.schedule_rounded, 'Captured', timestamp),
          if (notes.isNotEmpty) _detailRow(Icons.notes_rounded, 'Notes', notes),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 16, color: AppColors.success),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Available for internal TRA sharing',
                  style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textLow)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textHigh),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
