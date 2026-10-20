import 'package:flutter/material.dart';

import '../../core/catalog.dart';
import '../../core/requests.dart';
import '../certify/certification_screen.dart';
import '../piece/piece_screen.dart';
import '../shared/piece_image.dart';
import '../shared/ui.dart';

/// The curated collection: a calm two-column grid of verified pieces.
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  Category? _filter;

  @override
  Widget build(BuildContext context) {
    final catalog = context.catalog;
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final pieces = [for (final p in catalog.pieces) if (_filter == null || p.category == _filter) p];
    final categories = [for (final cat in Category.values) if (catalog.pieces.any((p) => p.category == cat)) cat];

    return SafeArea(
      bottom: false,
      child: CustomScrollView(slivers: [
        SliverPadding(
          padding: kPage,
          sliver: SliverToBoxAdapter(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
              Center(child: Text('HANDMARK', style: t.labelSmall?.copyWith(fontSize: 12, letterSpacing: 4))),
              const SizedBox(height: 24),
              const PageHeader(
                eyebrow: 'Autumn collection',
                title: 'Made by hand.\nProven by record.',
                subtitle: 'Each piece below was made by one maker and verified by us: '
                    'who made it, from what, where, and how many hours it took.',
              ),
              const _CertifyBanner(),
              const SizedBox(height: 28),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: kPage,
              children: [
                _chip('All', _filter == null, () => setState(() => _filter = null)),
                for (final cat in categories) _chip(cat.label, _filter == cat, () => setState(() => _filter = cat)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          sliver: SliverToBoxAdapter(
            child: Text('${pieces.length} ${pieces.length == 1 ? 'piece' : 'pieces'}',
                style: t.bodySmall?.copyWith(color: c.onSurfaceVariant)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) => SliverGrid(
              gridDelegate: pieceGridDelegate(context, constraints.crossAxisExtent),
              delegate: SliverChildBuilderDelegate((context, i) => PieceCard(piece: pieces[i]), childCount: pieces.length),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
      );
}

/// Entry point to "How we certify", right under the headline.
class _CertifyBanner extends StatelessWidget {
  const _CertifyBanner();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => openCertification(context),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(border: Border.all(color: c.secondary.withValues(alpha: 0.6))),
        child: Row(children: [
          Icon(Icons.verified_outlined, color: c.secondary, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('How we certify', style: t.titleMedium),
              const SizedBox(height: 2),
              Text('4 checks on every piece, plus FSC, hallmarks and other outside certificates verified at the source.',
                  style: t.bodySmall),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 18, color: c.onSurfaceVariant),
        ]),
      ),
    );
  }
}

/// Two columns whose cells fit the 4:5 image plus a two-line title, maker and price.
SliverGridDelegate pieceGridDelegate(BuildContext context, double width) {
  const gap = 16.0;
  final cell = (width - gap) / 2;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: gap,
    mainAxisSpacing: 32,
    mainAxisExtent: cell * 5 / 4 + MediaQuery.textScalerOf(context).scale(136),
  );
}

/// Photo, verified mark, title, maker, price.
class PieceCard extends StatelessWidget {
  const PieceCard({super.key, required this.piece});
  final Piece piece;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final maker = context.catalog.makerOf(piece);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openPiece(context, piece),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PieceImage(piece),
        const SizedBox(height: 12),
        const VerifiedBadge(compact: true),
        const SizedBox(height: 6),
        Text(piece.title, style: t.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(maker.name, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Text(usd(piece.priceUsd), style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
