import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareDocumentScreen extends StatefulWidget {
  const ShareDocumentScreen({
    required this.title,
    required this.referenceNumber,
    required this.notes,
    required this.attachedImagePaths,
    super.key,
  });

  final String title;
  final String referenceNumber;
  final String notes;
  final List<String> attachedImagePaths;

  @override
  State<ShareDocumentScreen> createState() => _ShareDocumentScreenState();
}

class _ShareDocumentScreenState extends State<ShareDocumentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<_TraStaff> _staff = <_TraStaff>[
    _TraStaff(name: 'John M. Komba', email: 'john.komba@tra.go.tz'),
    _TraStaff(name: 'Grace Nyerere', email: 'grace.nyerere@tra.go.tz'),
    _TraStaff(name: 'Peter Mwita', email: 'peter.mwita@tra.go.tz'),
    _TraStaff(name: 'Fatuma Mushi', email: 'fatuma.mushi@tra.go.tz'),
  ];

  String _shareMode = 'Staff';
  String _permission = 'View Only';
  String _expiry = '30 Days';
  bool _isSending = false;

  List<_TraStaff> get _filteredStaff {
    final String query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _staff;
    }
    return _staff
        .where((s) => s.name.toLowerCase().contains(query) || s.email.toLowerCase().contains(query))
        .toList();
  }

  List<_TraStaff> get _selectedStaff => _staff.where((s) => s.selected).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _shareSecurely() async {
    if (widget.attachedImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attach a document before sharing.')),
      );
      return;
    }

    final List<_TraStaff> recipients = _selectedStaff;

    if (recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one TRA staff member to share with.')),
      );
      return;
    }

    final bool invalidRecipient = recipients.any((r) => !r.email.endsWith('@tra.go.tz'));
    if (invalidRecipient) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only @tra.go.tz recipients are allowed.')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final String to = recipients.map((r) => r.email).join(';');
      final String subject = Uri.encodeComponent('TRA Document: ${widget.title}');
      final String body = Uri.encodeComponent(
        'A document has been shared with you within TRA.\n\n'
        'Title: ${widget.title}\n'
        'Reference: ${widget.referenceNumber}\n'
        'Attached Pages: ${widget.attachedImagePaths.length}\n'
        'Permission: $_permission\n'
        'Access Expiry: $_expiry\n'
        'Notes: ${widget.notes.isEmpty ? '-' : widget.notes}\n\n'
        'This share is intended for TRA network recipients only.',
      );

      final Uri composeUri = Uri.parse(
        'https://mail.tra.go.tz/owa/#path=/mail/action/compose&to=$to&subject=$subject&body=$body',
      );

      if (!await canLaunchUrl(composeUri)) {
        throw Exception('Cannot open compose url');
      }

      final bool launched = await launchUrl(composeUri, mode: LaunchMode.externalApplication);

      if (!mounted) {
        return;
      }

      if (!launched) {
        throw Exception('Launch failed');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening TRA Mail compose...')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      final Uri fallback = Uri.parse('https://mail.tra.go.tz/owa/');
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open compose directly. TRA Mail login page opened instead.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF022A78),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Share Document', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Share To', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _chipButton('Staff'),
                  const SizedBox(width: 8),
                  _chipButton('Department'),
                  const SizedBox(width: 8),
                  _chipButton('Group'),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search staff name or email...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD5DCEA)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListView.separated(
                    itemCount: _filteredStaff.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final _TraStaff staff = _filteredStaff[index];
                      return CheckboxListTile(
                        value: staff.selected,
                        activeColor: const Color(0xFF032C7B),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          setState(() {
                            staff.selected = value ?? false;
                          });
                        },
                        title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(staff.email),
                        secondary: const Icon(Icons.verified_user_outlined, color: Color(0xFF8B96AA)),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Permissions', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _styledDropdown<String>(
                value: _permission,
                items: const ['View Only', 'Can Comment', 'Can Edit'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _permission = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              const Text('Access Expiry', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _styledDropdown<String>(
                value: _expiry,
                items: const ['7 Days', '30 Days', '90 Days'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _expiry = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: Color(0xFF0C4A9A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.attachedImagePaths.isEmpty
                            ? 'No attached document found'
                            : '${widget.attachedImagePaths.length} page(s) attached and ready to share',
                        style: const TextStyle(color: Color(0xFF0C4A9A), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5D9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFD79D00)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recipients will be able to view this document within TRA network only.',
                        style: TextStyle(color: Color(0xFF5F4B00), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSending || widget.attachedImagePaths.isEmpty ? null : _shareSecurely,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCD00),
                    foregroundColor: const Color(0xFF102563),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Share Securely', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipButton(String label) {
    final bool selected = _shareMode == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _shareMode = label;
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF032C7B) : const Color(0xFFF0F2F6),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF4B5565),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5DCEA)),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _TraStaff {
  _TraStaff({required this.name, required this.email, this.selected = false});

  final String name;
  final String email;
  bool selected;
}
