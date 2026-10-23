import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tra_smart_scanner/services/document_registry.dart';

void main() {
  late Directory tmp;
  late List<String> pages;
  final registry = DocumentRegistry.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tmp = await Directory.systemTemp.createTemp('registry_test');
    pages = [];
    for (var i = 0; i < 2; i++) {
      final file = File('${tmp.path}/page$i.jpg')..writeAsBytesSync(List.generate(256, (b) => (b * (i + 3)) % 256));
      pages.add(file.path);
    }
  });

  tearDown(() => tmp.delete(recursive: true));

  Future<ScannedDocumentRecord> registerSample() =>
      registry.register(pagePaths: pages, title: 'Tax Guidelines', referenceNumber: 'TRA/1', notes: '');

  test('issues well-formed IDs with a valid check character', () async {
    final record = await registerSample();
    expect(record.id, matches(RegExp(r'^TRA-SS-\d{6}-[0-9A-Z]{8}-[0-9A-Z]$')));
    expect(registry.isWellFormed(record.id), isTrue);
  });

  test('every ID is unique', () async {
    final ids = <String>{};
    for (var i = 0; i < 200; i++) {
      ids.add((await registerSample()).id);
    }
    expect(ids.length, 200);
  });

  test('any single mistyped character is rejected', () async {
    final id = (await registerSample()).id;
    const alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    for (final pos in [7, 8, 12, 14, 18, 21, 23]) {
      for (final c in alphabet.split('')) {
        if (c == id[pos]) continue;
        final typo = id.replaceRange(pos, pos + 1, c);
        // Date positions only accept digits, so the pattern alone rejects letters there.
        expect(registry.isWellFormed(typo), isFalse, reason: typo);
      }
    }
  });

  test('verifies a registered ID and returns its record', () async {
    final record = await registerSample();
    final result = await registry.verify(record.id.toLowerCase());
    expect(result.status, VerificationStatus.verified);
    expect(result.record!.title, 'Tax Guidelines');
  });

  test('reports unknown and malformed IDs', () async {
    await registerSample();
    expect((await registry.verify('TRA-SS-000000-00000000-0')).status, VerificationStatus.notFound);
    expect((await registry.verify('hello')).status, VerificationStatus.invalidFormat);
  });

  test('QR payload verifies, and an altered fingerprint is flagged', () async {
    final record = await registerSample();
    expect((await registry.verify(record.qrPayload)).status, VerificationStatus.verified);

    final forged = '${DocumentRegistry.qrPrefix}${record.id}:${'0' * 64}';
    expect((await registry.verify(forged)).status, VerificationStatus.tampered);
  });

  test('merge combines pages in order under a new ID', () async {
    final a = await registerSample();
    final b = await registry.register(pagePaths: [pages[1]], title: 'Memo', referenceNumber: 'TRA/2', notes: '');

    final merged = await registry.merge([a, b], title: 'Combined');
    expect(merged.pagePaths, [...a.pagePaths, ...b.pagePaths]);
    expect(merged.pageCount, 3);
    expect(merged.mergedFrom, [a.id, b.id]);
    expect(merged.id, isNot(anyOf(a.id, b.id)));
    expect(merged.fingerprint, await DocumentRegistry.fingerprintPages(merged.pagePaths));

    final verified = await registry.verify(merged.id);
    expect(verified.status, VerificationStatus.verified);
    expect(verified.record!.isMerged, isTrue);
    expect((await registry.verify(a.id)).status, VerificationStatus.verified);

    expect((await registry.all()).first.id, merged.id);
  });

  test('changing one byte of a page changes the fingerprint', () async {
    final record = await registerSample();
    expect(await registry.pagesMatch(record, pages), isTrue);

    final bytes = File(pages[1]).readAsBytesSync()..[10] ^= 1;
    File(pages[1]).writeAsBytesSync(bytes);
    expect(await registry.pagesMatch(record, pages), isFalse);
  });
}
