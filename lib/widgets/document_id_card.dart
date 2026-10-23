import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/document_registry.dart';
import '../theme/app_theme.dart';
import 'app_ui.dart';

/// Bottom sheet confirming that [record] was issued its ID.
Future<void> showDocumentIdSheet(
  BuildContext context,
  ScannedDocumentRecord record, {
  required String title,
  required String message,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: IconTile(
                icon: Icons.verified_rounded,
                color: AppColors.success,
                background: AppColors.successSoft,
                size: 64,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textHigh),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMedium, height: 1.4),
            ),
            const SizedBox(height: 18),
            DocumentIdCard(record: record),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('Done')),
          ],
        ),
      ),
    ),
  );
}

/// QR code, unique ID and fingerprint of a registered document.
class DocumentIdCard extends StatelessWidget {
  const DocumentIdCard({required this.record, this.showQr = true, super.key});

  final ScannedDocumentRecord record;
  final bool showQr;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          if (showQr) ...[
            QrImageView(
              data: record.qrPayload,
              size: 168,
              padding: EdgeInsets.zero,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.textHigh),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textHigh,
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'DOCUMENT ID',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: AppColors.textLow),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                // Keep the ID on one line: wrapping at its hyphens makes it hard to read back.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SelectableText(
                    record.id,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.textHigh,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy ID',
                icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primaryDark),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: record.id));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document ID copied.')));
                },
              ),
            ],
          ),
          const Divider(height: 24),
          _row('Fingerprint', 'SHA-256 · ${record.shortFingerprint}…'),
          _row('Pages', '${record.pageCount}'),
          if (record.isMerged) _row('Merged from', '${record.mergedFrom.length} documents'),
          _row('Issued', _formatDate(record.issuedAt)),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMedium, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
