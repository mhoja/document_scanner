import 'package:flutter/material.dart';

class MyScansScreen extends StatelessWidget {
  const MyScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Scans"),
        backgroundColor: const Color(0xFF003087),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: "All"),
                Tab(text: "Pending"),
                Tab(text: "Synced"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildScansList("All"),
                  _buildScansList("Pending"),
                  _buildScansList("Synced"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScansList(String filter) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildScanItem("Tax Compliance Guidelines", "20 May 2024", "Synced"),
        _buildScanItem("HR Circular - Leave Policy", "19 May 2024", "Pending"),
        _buildScanItem("Office Memorandum", "18 May 2024", "Synced"),
      ],
    );
  }

  Widget _buildScanItem(String title, String date, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.description, color: Colors.blue, size: 40),
        title: Text(title),
        subtitle: Text(date),
        trailing: Chip(
          label: Text(status),
          backgroundColor: status == "Pending" ? Colors.orange[100] : Colors.green[100],
        ),
      ),
    );
  }
}