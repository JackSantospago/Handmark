import 'package:flutter/material.dart';

import '../../core/catalog.dart';
import '../../core/config.dart';
import '../../core/requests.dart';
import '../certify/certification_screen.dart';
import '../maker/maker_screen.dart';
import '../request/request_screen.dart';
import '../request/request_status_screen.dart';
import '../shared/piece_image.dart';
import '../shared/ui.dart';

void openPiece(BuildContext context, Piece piece) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PieceScreen(piece: piece)));

/// One piece: hero image, price, and the provenance record front and centre.
/// The primary action is "Request this piece" (no payment until the maker confirms).
class PieceScreen extends StatelessWidget {
  const PieceScreen({super.key, required this.piece});
  final Piece piece;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final maker = context.catalog.makerOf(piece);
    final open = context.requests.openFor(piece);

    return Scaffold(
      appBar: AppBar(title: Text(piece.category.label.toUpperCase())),
      body: ListView(padding: EdgeInsets.zero, children: [
        PieceImage(piece, aspectRatio: 4 / 4.6),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const VerifiedBadge(showInfo: true),
            const SizedBox(height: 10),
            Text(piece.title, style: t.headlineLarge),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => openMaker(context, maker),
              child: Text.rich(TextSpan(children: [
                TextSpan(text: 'by ', style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant)),
                TextSpan(
                  text: maker.name,
                  style: t.bodyMedium?.copyWith(decoration: TextDecoration.underline, decorationColor: c.outline),
                ),
                TextSpan(text: '  ·  ${piece.year}', style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant)),
              ])),
            ),
            const SizedBox(height: 20),
            Text(usd(piece.priceUsd), style: t.headlineSmall),
            const SizedBox(height: 4),
            Text('One of one  ·  ${piece.dimensions}', style: t.bodySmall),
            const SizedBox(height: 28),
            Text(piece.description, style: t.bodyLarge),
            const SizedBox(height: 40),
            _Provenance(piece: piece, maker: maker),
            const SizedBox(height: 40),
            const SectionLabel('The maker'),
            GroupCard(children: [
              RowTile(
                leading: MakerPortrait(maker, size: 52),
                title: maker.name,
                subtitle: '${maker.craft}, ${maker.location}',
                onTap: () => openMaker(context, maker),
              ),
            ]),
            const SizedBox(height: 32),
            Text(
              'Free returns within $kReturnDays days of delivery. A signed provenance certificate '
              'travels with every piece.',
              style: t.bodySmall,
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ]),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.outlineVariant))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: double.infinity,
                child: open == null
                    ? FilledButton(
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute<void>(builder: (_) => RequestScreen(piece: piece))),
                        child: const Text('Request this piece'),
                      )
                    : OutlinedButton(
                        onPressed: () => openRequest(context, open),
                        child: const Text('View your request'),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                'No payment now. ${maker.firstName} confirms availability within ${kConfirmWindow.inHours} hours.',
                style: t.bodySmall,
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// The record that makes Handmark different: who, what, how, how long, where,
/// and an honest line on any machine involvement.
class _Provenance extends StatelessWidget {
  const _Provenance({required this.piece, required this.maker});
  final Piece piece;
  final Maker maker;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(color: c.surfaceContainerLowest, border: Border.all(color: c.outline)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Provenance record', style: t.titleLarge)),
          Text(piece.verificationId, style: t.labelSmall?.copyWith(color: c.secondary, letterSpacing: 0.8)),
        ]),
        const SizedBox(height: 6),
        Text('Checked by Handmark: ${piece.verifiedHow}.', style: t.bodySmall),
        const SizedBox(height: 16),
        const ChecksStrip(),
        const SizedBox(height: 6),
        const Divider(),
        SpecRow(label: 'Hours of human work', value: '${piece.hours} hours', emphasis: true),
        const Divider(),
        SpecRow(label: 'Made by', value: maker.name, note: maker.craft),
        const Divider(),
        SpecRow(label: 'Materials', value: piece.materials.join('\n')),
        const Divider(),
        SpecRow(label: 'Method', value: piece.method),
        const Divider(),
        SpecRow(label: 'Made in', value: piece.origin, note: maker.workshop),
        const Divider(),
        SpecRow(label: 'Machine involvement', value: piece.machineNote),
        if (piece.certs.isNotEmpty) ...[
          Divider(color: c.outline),
          const SizedBox(height: 16),
          Text('EXTERNAL CERTIFICATIONS', style: t.labelSmall?.copyWith(color: c.onSurfaceVariant)),
          for (final (i, r) in piece.certs.indexed) ...[
            if (i > 0) const Divider(),
            CertResultRow(r),
          ],
        ],
        const Divider(),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => openCertification(context),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('How we certify'),
          ),
        ),
      ]),
    );
  }
}
