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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5B027),
        foregroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text('Tools', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8A8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF0D381)),
            ),
            child: const Text(
              "What's New",
              style: TextStyle(color: Color(0xFF8A6500), fontWeight: FontWeight.w600),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search, color: Color(0xFF111111)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Convert',
                style: TextStyle(color: Color(0xFF111111), fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 18,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
                children: const [
                  _ToolItem(icon: Icons.description, label: 'To Word', color: Color(0xFF5B7CFF)),
                  _ToolItem(icon: Icons.grid_on, label: 'To Excel', color: Color(0xFF22C55E)),
                  _ToolItem(icon: Icons.slideshow, label: 'To PPT', color: Color(0xFFFF7A59)),
                  _ToolItem(icon: Icons.image, label: 'To Images', color: Color(0xFF2DD4BF)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolItem extends StatelessWidget {
  const _ToolItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF111111), fontSize: 12, height: 1.1),
        ),
      ],
    );
  }
}