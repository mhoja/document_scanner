import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/document_registry.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';

class ShareDocumentScreen extends StatefulWidget {
  const ShareDocumentScreen({
    required this.title,
    required this.referenceNumber,
    required this.notes,
    required this.attachedImagePaths,
    this.record,
    super.key,
  });

  final String title;
  final String referenceNumber;
  final String notes;
  final List<String> attachedImagePaths;

  /// Registry entry of the scan, when it has been issued a document ID.
  final ScannedDocumentRecord? record;

  @override
  State<ShareDocumentScreen> createState() => _ShareDocumentScreenState();
}

class _ShareDocumentScreenState extends State<ShareDocumentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<_ShareRecipient> _recipients = <_ShareRecipient>[
    _ShareRecipient(category: 'Staff', name: 'Yusuph J. Mwenda', email: 'yusuph.mwenda@tra.go.tz'),
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
  bool _sendToAllStaff = false;
  bool _allStaffAsCc = false;

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

    if (recipients.isEmpty && !_sendToAllStaff) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one recipient or enable All Staff Group.')),
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
      final List<String> toRecipients = <String>[];
      final List<String> ccRecipients = <String>[];

      for (final _ShareRecipient recipient in recipients) {
        if (recipient.delivery == _DeliveryType.cc) {
          ccRecipients.add(recipient.email);
        } else {
          toRecipients.add(recipient.email);
        }
      }

      if (_sendToAllStaff) {
        if (_allStaffAsCc) {
          ccRecipients.add('group.allstaff@tra.go.tz');
        } else {
          toRecipients.add('group.allstaff@tra.go.tz');
        }
      }

      if (toRecipients.isEmpty && ccRecipients.isNotEmpty) {
        toRecipients.add(ccRecipients.removeAt(0));
      }

      if (toRecipients.isEmpty && ccRecipients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one To or CC recipient.')),
        );
        setState(() {
          _isSending = false;
        });
        return;
      }

      final String to = toRecipients.join(';');
      final String cc = ccRecipients.join(';');
      final String subject = Uri.encodeComponent('TRA Document: ${widget.title}');
      final String body = Uri.encodeComponent(
        'A document has been shared with you within TRA.\n\n'
        'Title: ${widget.title}\n'
        'Reference: ${widget.referenceNumber}\n'
        '${widget.record == null ? '' : 'Document ID: ${widget.record!.id}\n'
            'SHA-256 Fingerprint: ${widget.record!.fingerprint}\n'}'
        'Share Type: $_shareMode\n'
        'To Recipients: ${toRecipients.length}\n'
        'CC Recipients: ${ccRecipients.length}\n'
        'Attached Pages: ${widget.attachedImagePaths.length}\n'
        'Notes: ${widget.notes.isEmpty ? '-' : widget.notes}\n\n'
        '${widget.record == null ? '' : 'Verify this document in TRA SecureScan > Verify Document.\n'}'
        'This share is intended for TRA network recipients only.',
      );

      final Uri composeUri = Uri.parse(
        'https://mail.tra.go.tz/owa/#path=/mail/action/compose&to=$to&cc=$cc&subject=$subject&body=$body',
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
    final List<_ShareRecipient> filtered = _filteredRecipients;
    final int selectedCount = _selectedRecipients.length + (_sendToAllStaff ? 1 : 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Share Document')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        FadeSlideIn(child: _buildDocumentCard()),
                        const SizedBox(height: 22),
                        const SectionHeader('Share To'),
                        const SizedBox(height: 12),
                        PillSegmented(
                          options: const ['Staff', 'Department', 'Group'],
                          selected: _shareMode,
                          onChanged: (value) {
                            setState(() {
                              _shareMode = value;
                              _searchController.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search ${_shareMode.toLowerCase()} name or email...',
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAllStaffCard(),
                        const SizedBox(height: 18),
                        SectionHeader(
                          '$_shareMode Directory',
                          trailing: StatusBadge(label: '${filtered.length} available'),
                        ),
                        const SizedBox(height: 10),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: filtered.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 28),
                              child: Center(
                                child: Text('No matches found', style: TextStyle(color: AppColors.textMedium)),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildRecipientTile(filtered[index]),
                              childCount: filtered.length,
                            ),
                          ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverToBoxAdapter(
                      child: AppCard(
                        color: AppColors.successSoft,
                        borderColor: AppColors.successSoft,
                        shadow: const [],
                        padding: const EdgeInsets.all(14),
                        child: const Row(
                          children: [
                            Icon(Icons.verified_user_outlined, color: AppColors.success),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Recipients will be able to view this document within TRA network only.',
                                style: TextStyle(color: AppColors.success, fontSize: 13, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_file_rounded, size: 18, color: AppColors.primaryDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.attachedImagePaths.isEmpty
                              ? 'No attached document found'
                              : '${widget.attachedImagePaths.length} page(s) attached',
                          style:
                              const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          '$selectedCount recipient${selectedCount == 1 ? '' : 's'}',
                          key: ValueKey<int>(selectedCount),
                          style: const TextStyle(color: AppColors.textHigh, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isSending || widget.attachedImagePaths.isEmpty ? null : _shareSecurely,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                          )
                        : const Icon(Icons.lock_outline_rounded, size: 20),
                    label: const Text('Share Securely'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const IconTile(icon: Icons.shield_outlined, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textHigh),
                ),
                const SizedBox(height: 3),
                Text(
                  'Ref: ${widget.referenceNumber}',
                  style: const TextStyle(color: AppColors.textLow, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllStaffCard() {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      color: _sendToAllStaff ? AppColors.primaryTint : AppColors.surface,
      borderColor: _sendToAllStaff ? AppColors.primary : AppColors.border,
      shadow: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(icon: Icons.groups_rounded, size: 36),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Staff Group',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textHigh),
                    ),
                    Text(
                      'No manual selection needed',
                      style: TextStyle(color: AppColors.textLow, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _sendToAllStaff,
                onChanged: (value) {
                  setState(() {
                    _sendToAllStaff = value;
                  });
                },
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _sendToAllStaff
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Row(
                      children: [
                        _routeChip(
                          selected: !_allStaffAsCc,
                          label: 'To',
                          onTap: () {
                            setState(() {
                              _allStaffAsCc = false;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _routeChip(
                          selected: _allStaffAsCc,
                          label: 'CC',
                          onTap: () {
                            setState(() {
                              _allStaffAsCc = true;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'group.allstaff@tra.go.tz',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.textMedium, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientTile(_ShareRecipient recipient) {
    final bool isDepartment = recipient.category == 'Department';
    final bool isGroup = recipient.category == 'Group';

    final IconData badgeIcon = isDepartment
        ? Icons.apartment_rounded
        : isGroup
            ? Icons.groups_2_outlined
            : Icons.person_outline_rounded;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      color: recipient.selected ? AppColors.primaryTint : AppColors.surface,
      borderColor: recipient.selected ? AppColors.primary : AppColors.border,
      shadow: const [],
      onTap: () {
        setState(() {
          recipient.selected = !recipient.selected;
        });
      },
      child: Row(
        children: [
          Checkbox(
            value: recipient.selected,
            onChanged: (value) {
              setState(() {
                recipient.selected = value ?? false;
              });
            },
          ),
          IconTile(icon: badgeIcon, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textHigh),
                ),
                const SizedBox(height: 2),
                Text(
                  recipient.subtitle == null ? recipient.email : '${recipient.subtitle} • ${recipient.email}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textLow, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _routeChip(
            selected: recipient.selected && recipient.delivery == _DeliveryType.to,
            label: 'To',
            onTap: () {
              setState(() {
                recipient.delivery = _DeliveryType.to;
                recipient.selected = true;
              });
            },
          ),
          const SizedBox(width: 6),
          _routeChip(
            selected: recipient.selected && recipient.delivery == _DeliveryType.cc,
            label: 'CC',
            onTap: () {
              setState(() {
                recipient.delivery = _DeliveryType.cc;
                recipient.selected = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _routeChip({
    required bool selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.onPrimary : AppColors.textMedium,
            fontWeight: FontWeight.w700,
            fontSize: 11,
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
    this.delivery = _DeliveryType.to,
  });

  final String category;
  final String name;
  final String email;
  final String? subtitle;
  bool selected;
  _DeliveryType delivery;
}

enum _DeliveryType { to, cc }
