import 'dart:convert';
import 'dart:math';

import 'package:cross_file/cross_file.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A scanned document that has been issued a TRA SecureScan ID.
class ScannedDocumentRecord {
  const ScannedDocumentRecord({
    required this.id,
    required this.title,
    required this.referenceNumber,
    required this.notes,
    required this.pageCount,
    required this.fingerprint,
    required this.issuedAt,
    this.pagePaths = const [],
    this.mergedFrom = const [],
  });

  /// Unique, checksummed ID, e.g. `TRA-SS-261023-7K3QF9XA-M`.
  final String id;
  final String title;
  final String referenceNumber;
  final String notes;
  final int pageCount;

  /// SHA-256 of the page images (hex). Any change to a page changes it.
  final String fingerprint;
  final DateTime issuedAt;

  /// Where the page images live, in page order.
  final List<String> pagePaths;

  /// IDs of the documents this one was merged from; empty for a normal scan.
  final List<String> mergedFrom;

  bool get isMerged => mergedFrom.isNotEmpty;

  /// Short form of the fingerprint for display.
  String get shortFingerprint => fingerprint.substring(0, 16).toUpperCase();

  /// Payload encoded in the document's QR code.
  String get qrPayload => '${DocumentRegistry.qrPrefix}$id:$fingerprint';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'referenceNumber': referenceNumber,
        'notes': notes,
        'pageCount': pageCount,
        'fingerprint': fingerprint,
        'issuedAt': issuedAt.toIso8601String(),
        'pagePaths': pagePaths,
        'mergedFrom': mergedFrom,
      };

  factory ScannedDocumentRecord.fromJson(Map<String, dynamic> json) => ScannedDocumentRecord(
        id: json['id'] as String,
        title: json['title'] as String,
        referenceNumber: json['referenceNumber'] as String,
        notes: json['notes'] as String,
        pageCount: json['pageCount'] as int,
        fingerprint: json['fingerprint'] as String,
        issuedAt: DateTime.parse(json['issuedAt'] as String),
        pagePaths: List<String>.from(json['pagePaths'] as List? ?? const []),
        mergedFrom: List<String>.from(json['mergedFrom'] as List? ?? const []),
      );
}

enum VerificationStatus {
  /// The ID exists and (when a fingerprint was supplied) the content matches.
  verified,

  /// The ID exists but the supplied fingerprint does not match: the copy was altered.
  tampered,

  /// The ID is well-formed but was never issued.
  notFound,

  /// The ID is malformed or its check character is wrong (typo or forgery).
  invalidFormat,
}

class VerificationResult {
  const VerificationResult(this.status, [this.record]);

  final VerificationStatus status;
  final ScannedDocumentRecord? record;
}

/// Issues and verifies unique IDs for scanned documents.
///
/// Records are kept on the device. To make IDs verifiable across devices,
/// replace [_load]/[_save] with calls to a TRA verification API; the ID format,
/// fingerprint and [verify] logic stay the same.
class DocumentRegistry {
  DocumentRegistry._();

  static final DocumentRegistry instance = DocumentRegistry._();

  static const String qrPrefix = 'TRASS:1:';
  static const String _storageKey = 'document_registry_v1';

  // Crockford base32: no I, L, O or U, so IDs are easy to read aloud and retype.
  static const String _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  static final RegExp _idPattern = RegExp(r'^TRA-SS-(\d{6})-([0-9A-HJKMNP-TV-Z]{8})-([0-9A-HJKMNP-TV-Z])$');

  final Random _random = Random.secure();

  /// Fingerprints [pagePaths], assigns a new unique ID and stores the record.
  Future<ScannedDocumentRecord> register({
    required List<String> pagePaths,
    required String title,
    required String referenceNumber,
    required String notes,
    List<String> mergedFrom = const [],
  }) async {
    final records = await _load();
    final existingIds = records.map((r) => r.id).toSet();
    final now = DateTime.now();

    String id;
    do {
      id = _generateId(now);
    } while (existingIds.contains(id));

    final record = ScannedDocumentRecord(
      id: id,
      title: title,
      referenceNumber: referenceNumber,
      notes: notes,
      pageCount: pagePaths.length,
      fingerprint: await fingerprintPages(pagePaths),
      issuedAt: now,
      pagePaths: pagePaths,
      mergedFrom: mergedFrom,
    );
    await _save([...records, record]);
    return record;
  }

  /// Combines the pages of [sources], in order, into a new document with its
  /// own ID and fingerprint. The source documents keep their IDs.
  Future<ScannedDocumentRecord> merge(List<ScannedDocumentRecord> sources, {required String title}) {
    return register(
      pagePaths: [for (final s in sources) ...s.pagePaths],
      title: title,
      referenceNumber: sources.first.referenceNumber,
      notes: 'Merged from ${sources.map((s) => s.id).join(', ')}',
      mergedFrom: [for (final s in sources) s.id],
    );
  }

  /// Every issued document, newest first.
  Future<List<ScannedDocumentRecord>> all() async => (await _load())..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));

  /// Checks an ID typed by the user or a payload read from a document's QR code.
  Future<VerificationResult> verify(String input) async {
    String id = input.trim().toUpperCase();
    String? fingerprint;
    if (id.startsWith(qrPrefix)) {
      final parts = id.substring(qrPrefix.length).split(':');
      if (parts.length != 2) {
        return const VerificationResult(VerificationStatus.invalidFormat);
      }
      id = parts[0];
      fingerprint = parts[1].toLowerCase();
    }

    if (!isWellFormed(id)) {
      return const VerificationResult(VerificationStatus.invalidFormat);
    }

    final records = await _load();
    final matches = records.where((r) => r.id == id);
    if (matches.isEmpty) {
      return const VerificationResult(VerificationStatus.notFound);
    }
    final record = matches.first;
    if (fingerprint != null && fingerprint != record.fingerprint) {
      return VerificationResult(VerificationStatus.tampered, record);
    }
    return VerificationResult(VerificationStatus.verified, record);
  }

  /// Re-fingerprints a copy of the pages and compares it with the issued record.
  Future<bool> pagesMatch(ScannedDocumentRecord record, List<String> pagePaths) async =>
      await fingerprintPages(pagePaths) == record.fingerprint;

  /// True when [id] has the right shape and a valid check character.
  bool isWellFormed(String id) {
    final match = _idPattern.firstMatch(id);
    if (match == null) return false;
    return _checkChar('${match[1]}${match[2]}') == match[3];
  }

  /// SHA-256 over the per-page SHA-256 digests, in page order.
  static Future<String> fingerprintPages(List<String> pagePaths) async {
    final digests = <int>[];
    for (final path in pagePaths) {
      digests.addAll(sha256.convert(await XFile(path).readAsBytes()).bytes);
    }
    return sha256.convert(digests).toString();
  }

  String _generateId(DateTime date) {
    final yy = (date.year % 100).toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    final datePart = '$yy$mm$dd';
    final randomPart = List.generate(8, (_) => _alphabet[_random.nextInt(_alphabet.length)]).join();
    return 'TRA-SS-$datePart-$randomPart-${_checkChar('$datePart$randomPart')}';
  }

  /// Position-weighted mod-32 checksum. Odd weights are invertible mod 32, so
  /// any single wrong character is caught, as are most swapped neighbours.
  static String _checkChar(String body) {
    var sum = 0;
    for (var i = 0; i < body.length; i++) {
      sum += (2 * i + 1) * _alphabet.indexOf(body[i]);
    }
    return _alphabet[sum % _alphabet.length];
  }

  Future<List<ScannedDocumentRecord>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => ScannedDocumentRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _save(List<ScannedDocumentRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(records.map((r) => r.toJson()).toList()));
  }
}
