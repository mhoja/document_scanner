import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rounded white card with a hairline border and soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.radius = 20,
    this.shadow = AppShadows.soft,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final double radius;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Square icon badge on a tinted background.
class IconTile extends StatelessWidget {
  const IconTile({
    required this.icon,
    this.color = AppColors.primaryDark,
    this.background = AppColors.primarySoft,
    this.size = 44,
    super.key,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Small rounded label, e.g. "PDF" or "Synced".
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    this.color = AppColors.primaryDark,
    this.background = AppColors.primarySoft,
    super.key,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11, letterSpacing: 0.2),
      ),
    );
  }
}

/// Section title with an optional trailing widget.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textHigh),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Animated pill-style segmented selector.
class PillSegmented extends StatelessWidget {
  const PillSegmented({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.icons,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  /// Optional icon per option, in the same order as [options].
  final List<IconData>? icons;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: options.asMap().entries.map((entry) {
          final String option = entry.value;
          final IconData? icon = icons?[entry.key];
          final bool isSelected = option == selected;
          final Color foreground = isSelected ? AppColors.onPrimary : AppColors.textMedium;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? AppShadows.glow(AppColors.primary) : const [],
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 240),
                  style: TextStyle(
                    fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 17, color: foreground),
                        const SizedBox(width: 6),
                      ],
                      Flexible(child: Text(option, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Fades and slides its child in once, when first built.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({required this.child, this.index = 0, super.key});

  final Widget child;

  /// Position in a list; later items animate slightly longer for a stagger effect.
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index.clamp(0, 8) * 70)),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
        );
      },
    );
  }
}

class SelectionAction {
  const SelectionAction(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Full-width action bar docked at the bottom while items are selected;
/// takes the place of the bottom navigation bar.
class SelectionActionBar extends StatelessWidget {
  const SelectionActionBar({required this.actions, super.key});

  final List<SelectionAction> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: actions.map((action) {
              return Expanded(
                child: InkWell(
                  onTap: action.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(action.icon, color: AppColors.onPrimary, size: 22),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMedium, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class SheetOption {
  const SheetOption({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;
}

/// Light bottom sheets shared across screens.
class AppSheets {
  AppSheets._();

  static Future<String?> textInput(
    BuildContext context, {
    required String title,
    required String initialValue,
    String hint = '',
    String confirmLabel = 'Save',
    bool allowUnchanged = false,
  }) async {
    final TextEditingController controller = TextEditingController(text: initialValue);

    final String? value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textHigh)),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => Navigator.pop(sheetContext, controller.text.trim()),
                decoration: InputDecoration(hintText: hint),
              ),
              const SizedBox(height: 18),
              _SheetButtons(
                confirmLabel: confirmLabel,
                onCancel: () => Navigator.pop(sheetContext),
                onConfirm: () => Navigator.pop(sheetContext, controller.text.trim()),
              ),
            ],
          ),
        );
      },
    );

    controller.dispose();
    final String trimmed = (value ?? '').trim();
    if (trimmed.isEmpty || (!allowUnchanged && trimmed == initialValue)) {
      return null;
    }
    return trimmed;
  }

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    bool destructive = true,
  }) async {
    final bool? result = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTile(
                  icon: destructive ? Icons.delete_outline_rounded : Icons.help_outline_rounded,
                  color: destructive ? AppColors.danger : AppColors.primaryDark,
                  background: destructive ? AppColors.dangerSoft : AppColors.primarySoft,
                  size: 56,
                ),
                const SizedBox(height: 14),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textHigh)),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMedium, height: 1.4),
                ),
                const SizedBox(height: 22),
                _SheetButtons(
                  confirmLabel: confirmLabel,
                  destructive: destructive,
                  onCancel: () => Navigator.pop(sheetContext, false),
                  onConfirm: () => Navigator.pop(sheetContext, true),
                ),
              ],
            ),
          ),
        );
      },
    );

    return result == true;
  }

  static Future<String?> options(
    BuildContext context, {
    required List<SheetOption> options,
    String? title,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textHigh),
                    ),
                  ),
                ...options.map(
                  (option) => ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    leading: IconTile(icon: option.icon, size: 40),
                    title: Text(
                      option.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textHigh),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textLow),
                    onTap: () => Navigator.pop(sheetContext, option.value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SheetButtons extends StatelessWidget {
  const _SheetButtons({
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
    this.destructive = false,
  });

  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(onPressed: onCancel, child: const Text('Cancel')),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onConfirm,
            style: destructive
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white)
                : null,
            child: Text(confirmLabel),
          ),
        ),
      ],
    );
  }
}
