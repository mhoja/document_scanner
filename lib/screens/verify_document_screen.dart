import 'package:flutter/material.dart';

import '../services/document_registry.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import '../widgets/document_id_card.dart';

class VerifyDocumentScreen extends StatefulWidget {
  const VerifyDocumentScreen({super.key});

  @override
  State<VerifyDocumentScreen> createState() => _VerifyDocumentScreenState();
}

class _VerifyDocumentScreenState extends State<VerifyDocumentScreen> {
  final _idController = TextEditingController();
  VerificationResult? _result;
  bool _isChecking = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    if (_idController.text.trim().isEmpty) return;

    setState(() => _isChecking = true);
    final result = await DocumentRegistry.instance.verify(_idController.text);
    if (!mounted) return;
    setState(() {
      _result = result;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Document")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            const FadeSlideIn(
              child: Text(
                "Enter the Document ID printed on a TRA SecureScan document, or paste the text from its QR code.",
                style: TextStyle(color: AppColors.textMedium, height: 1.4),
              ),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              index: 1,
              child: TextField(
                controller: _idController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _verify(),
                decoration: const InputDecoration(
                  hintText: "TRA-SS-261023-XXXXXXXX-X",
                  prefixIcon: Icon(Icons.qr_code_2_rounded),
                ),
              ),
            ),
            const SizedBox(height: 14),
            FadeSlideIn(
              index: 2,
              child: ElevatedButton.icon(
                onPressed: _isChecking ? null : _verify,
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text("Verify"),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _statusBanner(_result!),
              if (_result!.record != null) ...[
                const SizedBox(height: 14),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _result!.record!.title,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textHigh),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Reference: ${_result!.record!.referenceNumber}",
                        style: const TextStyle(color: AppColors.textMedium),
                      ),
                      if (_result!.record!.isMerged) ...[
                        const SizedBox(height: 12),
                        const Text(
                          "Merged from",
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textHigh),
                        ),
                        for (final String sourceId in _result!.record!.mergedFrom)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text("• $sourceId", style: const TextStyle(color: AppColors.textMedium)),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                DocumentIdCard(record: _result!.record!, showQr: false),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBanner(VerificationResult result) {
    final (IconData icon, Color color, Color background, String title, String message) = switch (result.status) {
      VerificationStatus.verified => (
          Icons.verified_rounded,
          AppColors.success,
          AppColors.successSoft,
          "Genuine document",
          "This ID was issued by TRA SecureScan and the details below are the original record.",
        ),
      VerificationStatus.tampered => (
          Icons.gpp_bad_outlined,
          AppColors.danger,
          AppColors.dangerSoft,
          "Content does not match",
          "The ID exists, but this copy's fingerprint differs from the original. It may have been altered.",
        ),
      VerificationStatus.notFound => (
          Icons.help_outline_rounded,
          AppColors.warning,
          AppColors.warningSoft,
          "ID not found",
          "No document with this ID is registered. Treat this document as unverified.",
        ),
      VerificationStatus.invalidFormat => (
          Icons.error_outline_rounded,
          AppColors.danger,
          AppColors.dangerSoft,
          "Invalid document ID",
          "This is not a valid TRA SecureScan ID. Check for typing mistakes.",
        ),
    };

    return AppCard(
      color: background,
      borderColor: background,
      shadow: const [],
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: color)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: AppColors.textMedium, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
