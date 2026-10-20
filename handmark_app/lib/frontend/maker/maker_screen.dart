import 'package:flutter/material.dart';

import '../../core/catalog.dart';
import '../../core/requests.dart';
import '../browse/browse_screen.dart';
import '../certify/certification_screen.dart';
import '../shared/piece_image.dart';
import '../shared/ui.dart';

void openMaker(BuildContext context, Maker maker) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => MakerScreen(maker: maker)));

/// A maker's page: portrait, workshop, story, and their other listings.
class MakerScreen extends StatelessWidget {
  const MakerScreen({super.key, required this.maker});
  final Maker maker;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final pieces = context.catalog.piecesBy(maker.id);

    return Scaffold(
      appBar: AppBar(title: const Text('MAKER')),
      body: ListView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 40), children: [
        MakerPortrait(maker, aspectRatio: 4 / 3.6),
        const SizedBox(height: 24),
        Text(maker.craft.toUpperCase(), style: t.labelSmall?.copyWith(color: c.onSurfaceVariant)),
        const SizedBox(height: 10),
        Text(maker.name, style: t.headlineLarge),
        const SizedBox(height: 10),
        const VerifiedBadge(showInfo: true),
        const SizedBox(height: 20),
        GroupCard(children: [
          SpecRow(label: 'Workshop', value: maker.location, note: maker.workshop),
          SpecRow(label: 'Working since', value: '${maker.since}'),
          InkWell(
            onTap: () => openCertification(context),
            child: SpecRow(
              label: 'Verified',
              value: maker.verifiedOn,
              note: 'All four Handmark checks passed. Next re-verification ${maker.reviewDue}.',
            ),
          ),
          SpecRow(label: 'On Handmark', value: '${pieces.length} verified ${pieces.length == 1 ? 'piece' : 'pieces'}'),
        ]),
        const SizedBox(height: 32),
        for (final para in maker.story) ...[
          Text(para, style: t.bodyLarge),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.only(left: 18),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: c.secondary, width: 2))),
          child: Text('“${maker.quote}”', style: t.headlineSmall?.copyWith(fontStyle: FontStyle.italic, height: 1.3)),
        ),
        const SizedBox(height: 48),
        SectionLabel('Work by ${maker.firstName}'),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) => GridView(
            gridDelegate: pieceGridDelegate(context, constraints.maxWidth),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [for (final p in pieces) PieceCard(piece: p)],
          ),
        ),
      ]),
    );
  }
}

/// The Makers tab: everyone currently on Handmark.
class MakersScreen extends StatelessWidget {
  const MakersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.catalog;
    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 40), children: [
        const PageHeader(
          eyebrow: 'Makers',
          title: 'The hands behind the work',
          subtitle: 'We visit every workshop, in person or on camera, before a single piece is listed.',
        ),
        GroupCard(children: [
          for (final m in catalog.makers)
            RowTile(
              leading: MakerPortrait(m, size: 60),
              title: m.name,
              subtitle: '${m.craft}  ·  ${m.location}',
              onTap: () => openMaker(context, m),
            ),
        ]),
      ]),
    );
  }
}
