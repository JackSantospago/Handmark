import 'package:flutter/material.dart';

import '../certify/certification_screen.dart';

/// Small building blocks shared by every page so they look like one product:
/// a big serif page title, quiet small-caps section labels, and hairline
/// groups. Icons are thin outlines; colour is kept for the verified mark.

/// Big serif title at the top of a page, with an optional small-caps eyebrow
/// above and a one-line subtitle below.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.eyebrow, this.subtitle, this.trailing});
  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(), style: t.labelSmall?.copyWith(color: c.onSurfaceVariant)),
          const SizedBox(height: 10),
        ],
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Text(title, style: t.headlineLarge)),
          ?trailing,
        ]),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(subtitle!, style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant)),
        ],
      ]),
    );
  }
}

/// Small-caps label above a group, with an optional action on the right ("See all").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.action, this.onAction});
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(child: Text(text.toUpperCase(), style: t.labelSmall?.copyWith(color: c.onSurfaceVariant))),
        if (action != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 4)),
            child: Text(action!),
          ),
      ]),
    );
  }
}

/// Rows separated by hairlines, with a hairline above and below.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.symmetric(horizontal: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(),
            children[i],
          ],
        ]),
      );
}

/// One row in a [GroupCard]: optional leading, title, optional subtitle and trailing.
class RowTile extends StatelessWidget {
  const RowTile({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleStyle,
    this.leading,
  });
  final IconData? icon;

  /// Instead of [icon], any widget (e.g. a thumbnail).
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ] else if (icon != null) ...[
            Icon(icon, size: 20, color: c.onSurfaceVariant),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: titleStyle ?? t.titleMedium),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(subtitle!, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ]),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 150), child: trailing!),
          ] else if (onTap != null)
            Icon(Icons.arrow_forward, size: 18, color: c.onSurfaceVariant),
        ]),
      ),
    );
  }
}

/// The trust mark: a thin brass seal and small-caps "Handmark Verified".
/// Tapping it anywhere opens "How we certify".
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.compact = false, this.showInfo = false});
  final bool compact;

  /// Adds a small info mark, hinting that the badge can be tapped.
  final bool showInfo;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openCertification(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.verified_outlined, size: compact ? 13 : 15, color: c.secondary),
      SizedBox(width: compact ? 5 : 6),
      Text(
        'HANDMARK VERIFIED',
        style: t.labelSmall?.copyWith(color: c.secondary, fontSize: compact ? 9 : 10.5, letterSpacing: compact ? 1.1 : 1.4),
      ),
      if (showInfo) ...[
        const SizedBox(width: 6),
        Icon(Icons.info_outline, size: 14, color: c.secondary),
      ],
        ]),
      ),
    );
  }
}

/// A label / value line of a record (provenance, order summary).
class SpecRow extends StatelessWidget {
  const SpecRow({super.key, required this.label, required this.value, this.emphasis = false, this.note});
  final String label, value;
  final String? note;

  /// Value in the serif, larger (e.g. hours of human work).
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 112,
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(label.toUpperCase(), style: t.labelSmall?.copyWith(color: c.onSurfaceVariant, fontSize: 9.5)),
          ),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: emphasis ? t.headlineSmall : t.bodyMedium),
            if (note != null) ...[
              const SizedBox(height: 4),
              Text(note!, style: t.bodySmall),
            ],
          ]),
        ),
      ]),
    );
  }
}

/// Page padding used by every screen.
const kPage = EdgeInsets.symmetric(horizontal: 24);

/// "Thu 22 Oct, 14:05"
String shortDateTime(DateTime d) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String two(int v) => v.toString().padLeft(2, '0');
  return '${days[d.weekday - 1]} ${d.day} ${months[d.month - 1]}, ${two(d.hour)}:${two(d.minute)}';
}
