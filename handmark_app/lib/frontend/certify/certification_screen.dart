import 'package:flutter/material.dart';

import '../../core/certification.dart';
import '../shared/ui.dart';

/// Opens "How we certify". [scheme] scrolls to one external certification.
void openCertification(BuildContext context, {String? scheme}) => Navigator.of(context)
    .push(MaterialPageRoute<void>(builder: (_) => CertificationScreen(focusScheme: scheme)));

/// Everything a buyer needs to trust the mark: our four checks, what the mark
/// does and does not promise, how hours are checked, the external
/// certifications we verify, and what happens when a claim fails.
class CertificationScreen extends StatefulWidget {
  const CertificationScreen({super.key, this.focusScheme});
  final String? focusScheme;

  @override
  State<CertificationScreen> createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen> {
  final _schemeKeys = {for (final s in certSchemes) s.id: GlobalKey()};

  @override
  void initState() {
    super.initState();
    final key = _schemeKeys[widget.focusScheme];
    if (key != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = key.currentContext;
        if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 500), alignment: 0.1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('CERTIFICATION')),
      // A Column in a scroll view (not a lazy ListView) so every scheme has a
      // laid-out position to scroll to.
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const _Hero(),
          const SizedBox(height: 48),

          // ------------------------------------------------ our four checks
          const SectionLabel('Our four checks'),
          Text('Every piece passes all four before it carries the mark.', style: t.headlineSmall),
          const SizedBox(height: 24),
          for (final (i, check) in handmarkChecks.indexed) _CheckCard(index: i, check: check),
          const SizedBox(height: 40),

          // ------------------------------------------------ promises
          const SectionLabel('What the mark means'),
          const _PromiseList(),
          const SizedBox(height: 40),

          // ------------------------------------------------ hours
          const SectionLabel('Hours of human work'),
          Text('How we check the number', style: t.headlineSmall),
          const SizedBox(height: 12),
          Text(
            'Makers log their hours as they work. We compare the log with the dated work-in-progress '
            'photos and with pieces of the same craft and size. If the number is out of line, we ask '
            'why, and we publish it only when the explanation holds up. It is an honest estimate, '
            'not a stopwatch reading, and we say so.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 48),

          // ------------------------------------------------ external
          const SectionLabel('External certifications'),
          Text('Checked at the source', style: t.headlineSmall),
          const SizedBox(height: 12),
          Text(
            "When a maker claims an outside certification, we look it up on the issuing body's own "
            'public register and match it to the invoice for this piece. We never show a certification '
            'we have not checked ourselves.',
            style: t.bodyMedium,
          ),
          const SizedBox(height: 24),
          const SectionLabel('Three possible results on a listing'),
          const _ResultLegend(),
          const SizedBox(height: 28),
          for (final s in certSchemes) _SchemeCard(key: _schemeKeys[s.id], scheme: s, focused: s.id == widget.focusScheme),
          const SizedBox(height: 40),

          // ------------------------------------------------ enforcement
          const SectionLabel('Keeping it true'),
          GroupCard(children: const [
            RowTile(
              icon: Icons.event_repeat_outlined,
              title: 'Re-verified every 12 months',
              subtitle: 'Each maker and workshop is checked again yearly, plus unannounced video spot checks.',
            ),
            RowTile(
              icon: Icons.flag_outlined,
              title: 'Anyone can raise a concern',
              subtitle: 'Buyers and other makers can report a listing. We investigate within 5 working days.',
            ),
            RowTile(
              icon: Icons.undo_outlined,
              title: 'If a claim fails, you are refunded',
              subtitle: 'The listing comes down, the maker loses the mark, and buyers of affected pieces get a full refund.',
            ),
          ]),
          const SizedBox(height: 32),
          Text(
            'Demo content: the process is the proposed Handmark standard. Certificate numbers, dates and '
            'results shown on pieces are invented for this prototype. Scheme logos are not reproduced.',
            style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
          ),
        ]),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final ink = c.onInverseSurface;
    Widget stat(String big, String small) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(big, style: t.headlineMedium?.copyWith(color: ink)),
            const SizedBox(height: 4),
            Text(small, style: t.bodySmall?.copyWith(color: ink.withValues(alpha: 0.7))),
          ]),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      color: c.inverseSurface,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.verified_outlined, size: 30, color: c.brightness == Brightness.light ? const Color(0xFFC9A86E) : c.secondary),
          const SizedBox(width: 10),
          Text('HANDMARK VERIFIED',
              style: t.labelSmall?.copyWith(color: const Color(0xFFC9A86E), fontSize: 11.5, letterSpacing: 1.8)),
        ]),
        const SizedBox(height: 20),
        Text('How we certify every maker and every piece', style: t.headlineLarge?.copyWith(color: ink)),
        const SizedBox(height: 12),
        Text(
          'Handmade is easy to claim and hard to prove. The mark means we checked, with our own eyes '
          'and against outside records, who made the piece, how, and from what.',
          style: t.bodyMedium?.copyWith(color: ink.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 24),
        Divider(color: ink.withValues(alpha: 0.2)),
        const SizedBox(height: 18),
        Row(children: [stat('4', 'checks per piece'), stat('100%', 'workshops visited'), stat('12 mo', 'between re-checks')]),
      ]),
    );
  }
}

/// "The maker" -> "Maker"
String _shortTitle(String title) {
  final s = title.replaceFirst('The ', '');
  return s[0].toUpperCase() + s.substring(1);
}

const _checkIcons = [Icons.person_outline, Icons.back_hand_outlined, Icons.forest_outlined, Icons.inventory_2_outlined];

class _CheckCard extends StatelessWidget {
  const _CheckCard({required this.index, required this.check});
  final int index;
  final VerificationCheck check;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: c.surfaceContainerLowest, border: Border.all(color: c.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('0${index + 1}', style: t.headlineSmall?.copyWith(color: c.secondary)),
          const SizedBox(width: 14),
          Expanded(child: Text(check.title, style: t.titleLarge)),
          Icon(_checkIcons[index], size: 22, color: c.onSurfaceVariant),
        ]),
        const SizedBox(height: 10),
        Text(check.summary, style: t.bodyMedium),
        const SizedBox(height: 14),
        for (final e in check.evidence)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 2), child: Icon(Icons.check, size: 15, color: c.secondary)),
              const SizedBox(width: 10),
              Expanded(child: Text(e, style: t.bodySmall?.copyWith(color: c.onSurface))),
            ]),
          ),
      ]),
    );
  }
}

class _PromiseList extends StatelessWidget {
  const _PromiseList();

  static const _yes = [
    'Made by the named maker, in the workshop shown',
    'Materials traced, and any outside certification checked',
    'Hours of human work checked against evidence',
    'Every machine step disclosed on the listing',
  ];
  static const _no = [
    'That no machine was ever used. Some steps are better done by one, and we say which',
    'That hours are timed to the minute. They are a checked estimate',
    'That every material carries an outside certificate. When none applies, we say why',
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    Widget line(String s, bool yes) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(yes ? Icons.check : Icons.remove, size: 17, color: yes ? c.secondary : c.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(s, style: t.bodyMedium?.copyWith(color: yes ? c.onSurface : c.onSurfaceVariant))),
          ]),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('It promises', style: t.titleMedium),
      const SizedBox(height: 6),
      for (final s in _yes) line(s, true),
      const SizedBox(height: 18),
      Text('It does not promise', style: t.titleMedium),
      const SizedBox(height: 6),
      for (final s in _no) line(s, false),
    ]);
  }
}

class _ResultLegend extends StatelessWidget {
  const _ResultLegend();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget row(CertStatus s, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 132, child: CertStatusLabel(s)),
            Expanded(child: Text(text, style: t.bodySmall)),
          ]),
        );
    return GroupCard(children: [
      row(CertStatus.verified, 'Claimed by the maker and confirmed by us on the issuer\'s register.'),
      row(CertStatus.notCertified, 'A scheme exists but this piece is not certified. We give the reason.'),
      row(CertStatus.notApplicable, 'No outside scheme covers this kind of work. Our own checks still apply.'),
    ]);
  }
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({super.key, required this.scheme, required this.focused});
  final CertScheme scheme;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surfaceContainerLowest,
        border: Border.all(color: focused ? c.secondary : c.outlineVariant, width: focused ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CertSeal(scheme.seal),
          const SizedBox(width: 16),
          Expanded(child: Text(scheme.name, style: t.titleMedium)),
        ]),
        const SizedBox(height: 16),
        Text('WHAT IT CERTIFIES', style: t.labelSmall?.copyWith(color: c.onSurfaceVariant, fontSize: 9.5)),
        const SizedBox(height: 4),
        Text(scheme.certifies, style: t.bodyMedium),
        const SizedBox(height: 14),
        Text('HOW WE CHECK IT', style: t.labelSmall?.copyWith(color: c.secondary, fontSize: 9.5)),
        const SizedBox(height: 4),
        Text(scheme.howWeCheck, style: t.bodyMedium),
        const SizedBox(height: 14),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final cat in scheme.appliesTo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: c.outline)),
              child: Text(cat.label, style: t.labelSmall?.copyWith(letterSpacing: 0.4, fontSize: 10.5)),
            ),
        ]),
      ]),
    );
  }
}

/// Neutral text seal for an external scheme (logos are not reproduced).
class CertSeal extends StatelessWidget {
  const CertSeal(this.text, {super.key, this.size = 48});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final lines = text.split('\n').length;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all(color: c.onSurface, width: 1.2)),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: t.labelSmall?.copyWith(
          color: c.onSurface,
          fontSize: (lines > 1 ? 8.5 : 11) * size / 48,
          letterSpacing: 0.8,
          height: 1.15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// "Verified" / "Not certified" / "No scheme applies", with a mark.
class CertStatusLabel extends StatelessWidget {
  const CertStatusLabel(this.status, {super.key});
  final CertStatus status;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final (icon, text, color) = switch (status) {
      CertStatus.verified => (Icons.check_circle, 'VERIFIED', c.secondary),
      CertStatus.notCertified => (Icons.do_not_disturb_on_outlined, 'NOT CERTIFIED', c.onSurfaceVariant),
      CertStatus.notApplicable => (Icons.radio_button_unchecked, 'NO SCHEME', c.onSurfaceVariant),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 6),
      Text(text, style: t.labelSmall?.copyWith(color: color, fontSize: 9.5, letterSpacing: 1.1)),
    ]);
  }
}

/// One external certification result on a piece; tap for how we check it.
class CertResultRow extends StatelessWidget {
  const CertResultRow(this.record, {super.key});
  final CertRecord record;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = schemeById(record.schemeId);
    return InkWell(
      onTap: () => openCertification(context, scheme: scheme?.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CertSeal(scheme?.seal ?? 'N/A', size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(scheme?.name ?? 'No external scheme', style: t.titleSmall),
              const SizedBox(height: 4),
              CertStatusLabel(record.status),
              const SizedBox(height: 6),
              Text(record.detail, style: t.bodySmall),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// The four Handmark checks as a compact strip of ticks; tap for the full page.
class ChecksStrip extends StatelessWidget {
  const ChecksStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => openCertification(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        color: c.secondaryContainer.withValues(alpha: 0.5),
        child: Row(children: [
          for (final (i, check) in handmarkChecks.indexed)
            Expanded(
              child: Column(children: [
                Icon(_checkIcons[i], size: 18, color: c.onSurface),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.check, size: 11, color: c.secondary),
                  const SizedBox(width: 2),
                  Flexible(child: Text(_shortTitle(check.title), style: t.labelMedium?.copyWith(fontSize: 11))),
                ]),
              ]),
            ),
        ]),
      ),
    );
  }
}
