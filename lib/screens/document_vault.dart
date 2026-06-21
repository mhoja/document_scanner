// import 'package:flutter/material.dart';

// class DocumentVaultScreen extends StatelessWidget {
//   const DocumentVaultScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Document Vault")),
//       body: const Center(
//         child: Text("Document Vault Screen\n(Coming Soon)"),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class DocumentVaultScreen extends StatelessWidget {
  const DocumentVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Vault"),
        backgroundColor: const Color(0xFF003087),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search title, content, reference...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text("All (245)", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003087))),
                Text("Recent"),
                Text("Favorites"),
                Text("Shared"),
                Text("Archived"),
              ],
            ),
          ),

          const Divider(),

          // Document List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDocumentItem("Tax Compliance Guidelines", "TCG/2026/001", "20 May 2024"),
                _buildDocumentItem("HR Circular - Leave Policy", "HR/CR/2026/002", "19 May 2024"),
                _buildDocumentItem("Office Memorandum", "TRADM/2024/045", "18 May 2024"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, String ref, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("$ref • $date"),
        trailing: const Icon(Icons.star_border),
      ),
    );
  }
}