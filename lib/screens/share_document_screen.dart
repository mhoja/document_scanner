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
  static const Color _primaryBlue = Color(0xFF1F56FF);
  static const Color _deepBlue = Color(0xFF0C2D7A);
  static const Color _mint = Color(0xFF16B8A6);
  static const Color _pageBg = Color(0xFFF3F7FF);

  final TextEditingController _searchController = TextEditingController();
  final List<_ShareRecipient> _recipients = <_ShareRecipient>[
    _ShareRecipient(category: 'Staff', name: 'John M. Komba', email: 'john.komba@tra.go.tz'),
    _ShareRecipient(category: 'Staff', name: 'Grace Nyerere', email: 'grace.nyerere@tra.go.tz'),
    _ShareRecipient(category: 'Staff', name: 'Peter Mwita', email: 'peter.mwita@tra.go.tz'),
    _ShareRecipient(category: 'Staff', name: 'Fatuma Mushi', email: 'fatuma.mushi@tra.go.tz'),
    _ShareRecipient(category: 'Department', name: 'ICT', email: 'department.ict@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'DRD', email: 'department.drd@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'LTD', email: 'department.ltd@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'HRMAD', email: 'department.hrmad@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'LSD', email: 'department.lsd@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'INAD', email: 'department.inad@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'CE', email: 'department.ce@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'FND', email: 'department.fnd@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'RPD', email: 'department.rpd@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'PMD', email: 'department.pmd@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(category: 'Department', name: 'TID', email: 'department.tid@tra.go.tz', subtitle: 'Department'),
    _ShareRecipient(
      category: 'Group',
      name: 'ICT Systems and Database Management',
      email: 'group.sdm@tra.go.tz',
      subtitle: 'Specialized Group',
    ),
    _ShareRecipient(
      category: 'Group',
      name: 'Security',
      email: 'group.security@tra.go.tz',
      subtitle: 'Security Group',
    ),
  ];

  String _shareMode = 'Staff';
  bool _isSending = false;

  List<_ShareRecipient> get _filteredRecipients {
    final String query = _searchController.text.trim().toLowerCase();
    return _recipients
        .where((r) => r.category == _shareMode)
        .where((r) => query.isEmpty || r.name.toLowerCase().contains(query) || r.email.toLowerCase().contains(query))
        .toList();
  }

  List<_ShareRecipient> get _selectedRecipients => _recipients.where((r) => r.selected).toList();

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

    final List<_ShareRecipient> recipients = _selectedRecipients;

    if (recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Select at least one $_shareMode recipient to share with.')),
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
        'Share Type: $_shareMode\n'
        'Attached Pages: ${widget.attachedImagePaths.length}\n'
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
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _deepBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A2A76), Color(0xFF2A63FF)],
            ),
          ),
        ),
        title: const Text('Share Document', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEAF1FF), Color(0xFFF7FAFF), Color(0xFFFFFFFF)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFFEFF4FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD9E5FF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.95),
                        blurRadius: 14,
                        offset: const Offset(-1, -1),
                      ),
                      BoxShadow(
                        color: _primaryBlue.withValues(alpha: 0.09),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1746D9), Color(0xFF2F6BFF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shield_outlined, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF102563),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ref: ${widget.referenceNumber}',
                              style: const TextStyle(
                                color: Color(0xFF5770A3),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Share To', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1A2E61))),
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
                    hintText: 'Search ${_shareMode.toLowerCase()} name or email...',
                    hintStyle: const TextStyle(color: Color(0xFF7E8FAF)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF4762A1)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD5DFF5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF2F6BFF), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDCE5F8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.groups_2_outlined, size: 18, color: Color(0xFF3C5694)),
                      const SizedBox(width: 8),
                      Text(
                        '$_shareMode Directory • ${_filteredRecipients.length} available',
                        style: const TextStyle(
                          color: Color(0xFF425A93),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFFFFF), Color(0xFFF5F9FF)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDCE5F8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.95),
                          blurRadius: 16,
                          offset: const Offset(-1, -1),
                        ),
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      itemCount: _filteredRecipients.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE7EDF9)),
                      itemBuilder: (context, index) {
                        final _ShareRecipient recipient = _filteredRecipients[index];
                        return _buildRecipientTile(recipient);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEFF7FF), Color(0xFFE5F2FF)],
                    ),
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
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEFFDF6), Color(0xFFE3FAF1)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Color(0xFF1E8C73)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recipients will be able to view this document within TRA network only.',
                          style: TextStyle(color: Color(0xFF176A57), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A4CE4), Color(0xFF2E9CFF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _isSending || widget.attachedImagePaths.isEmpty ? null : _shareSecurely,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Share Securely', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipientTile(_ShareRecipient recipient) {
    final bool isDepartment = recipient.category == 'Department';
    final bool isGroup = recipient.category == 'Group';

    final Color badgeBg = isDepartment
        ? const Color(0xFFE7F1FF)
        : isGroup
            ? const Color(0xFFEEE8FF)
            : _mint.withValues(alpha: 0.15);

    final Color badgeIconColor = isDepartment
        ? const Color(0xFF2A62D8)
        : isGroup
            ? const Color(0xFF6A4BD8)
            : const Color(0xFF148C7A);

    final IconData badgeIcon = isDepartment
        ? Icons.apartment_rounded
        : isGroup
            ? Icons.groups_2_outlined
            : Icons.verified_user_outlined;

    return CheckboxListTile(
      value: recipient.selected,
      activeColor: _primaryBlue,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      onChanged: (value) {
        setState(() {
          recipient.selected = value ?? false;
        });
      },
      title: Text(
        recipient.name,
        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF172E64)),
      ),
      subtitle: Text(
        recipient.subtitle == null ? recipient.email : '${recipient.subtitle} • ${recipient.email}',
        style: const TextStyle(color: Color(0xFF6278A4)),
      ),
      secondary: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(badgeIcon, color: badgeIconColor, size: 20),
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
            _searchController.clear();
          });
        },
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1846DA), Color(0xFF2B64FF)],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF5F8FF), Color(0xFFEDF2FF)],
                  ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? const Color(0xFF2F6BFF) : const Color(0xFFD8E2F8),
            ),
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
}

class _ShareRecipient {
  _ShareRecipient({
    required this.category,
    required this.name,
    required this.email,
    this.subtitle,
    this.selected = false,
  });

  final String category;
  final String name;
  final String email;
  final String? subtitle;
  bool selected;
}
