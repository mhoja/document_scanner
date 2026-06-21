import 'package:flutter/material.dart';
import 'document_detail_screen.dart';

class MyScansScreen extends StatelessWidget {
  const MyScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navy = const Color(0xFF003E7E);
    final yellow = const Color(0xFFFFB400);

    return Scaffold(
      appBar: AppBar(title: const Text("My Scans"), backgroundColor: navy),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DocumentDetailScreen(
                      title: 'Circular on Working Hours',
                      date: '20 May 2024',
                      status: 'Pending',
                      referenceNumber: 'TRA/ADM/2024/05',
                      notes: 'This circular outlines the new office working hours effective from 21st May 2024.',
                      scannedBy: 'John M. Komba',
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: navy.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.description, color: Color(0xFF003E7E)),
                ),
                title: const Text("Circular on Working Hours", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("20 May 2024"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: yellow.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: const Text("Pending", style: TextStyle(color: Color(0xFFB35E00))),
                ),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DocumentDetailScreen(
                      title: 'Office Notice - 05/2024',
                      date: '19 May 2024',
                      status: 'Synced',
                      referenceNumber: 'TRA/ADM/2024/06',
                      notes: 'A scanned copy of the office notice saved in your document library.',
                      scannedBy: 'John M. Komba',
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(color: Colors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.description, color: Colors.green),
                ),
                title: const Text("Office Notice - 05/2024", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("19 May 2024"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: const Text("Synced", style: TextStyle(color: Colors.green)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}