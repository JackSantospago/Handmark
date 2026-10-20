import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/catalog.dart';
import '../../core/config.dart';
import '../../core/requests.dart';
import '../shared/ui.dart';
import 'request_screen.dart';

void openRequest(BuildContext context, OrderRequest r) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => RequestStatusScreen(request: r)));

/// Where a request stands. The 48-hour maker confirmation is shown as its own
/// step with a live countdown: it is a product decision, not a delay.
class RequestStatusScreen extends StatefulWidget {
  const RequestStatusScreen({super.key, required this.request});
  final OrderRequest request;

  @override
  State<RequestStatusScreen> createState() => _RequestStatusScreenState();
}

class _RequestStatusScreenState extends State<RequestStatusScreen> {
  late final Timer _tick;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200)); // demo: no real payment
    if (!mounted) return;
    context.requests.pay(widget.request);
    setState(() => _paying = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    context.requests; // rebuild when the store changes
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final maker = context.catalog.makerOf(r.piece);
    final now = DateTime.now();

    final (eyebrow, title, subtitle) = switch (r.stage) {
      RequestStage.awaitingMaker => (
          'Request ${r.id}  ·  sent',
          'Waiting for ${maker.firstName}',
          '${maker.firstName} has until ${when(r.confirmBy)} to confirm the piece is available. '
              'It is held for you until then, and nothing has been charged.',
        ),
      RequestStage.confirmed => (
          'Request ${r.id}  ·  confirmed',
          'Ready for payment',
          '${maker.firstName} confirmed on ${when(r.confirmedAt!)}. The piece is held for you '
              'for ${kPaymentWindow.inHours} hours while you finalise payment.',
        ),
      RequestStage.paid => (
          'Request ${r.id}  ·  complete',
          'It\'s yours',
          '${maker.firstName} will pack and ship within $kShipWithinDays days. A signed provenance '
              'certificate (${r.piece.verificationId}) travels with the piece.',
        ),
      RequestStage.declined => (
          'Request ${r.id}  ·  closed',
          'Not available this time',
          '${maker.firstName} could not confirm this piece. You were not charged. We will tell you '
              'when ${maker.firstName} lists new work.',
        ),
    };

    final step = switch (r.stage) {
      RequestStage.awaitingMaker => 1,
      RequestStage.confirmed => 2,
      RequestStage.paid => 3,
      RequestStage.declined => 1,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('YOUR REQUEST')),
      body: ListView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 40), children: [
        PageHeader(eyebrow: eyebrow, title: title, subtitle: subtitle),
        Row(children: [
          RequestThumb(r, size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.piece.title, style: t.titleMedium),
              Text(maker.name, style: t.bodySmall),
            ]),
          ),
          Text(usd(r.piece.priceUsd), style: t.bodyMedium),
        ]),
        const SizedBox(height: 32),
        RequestSteps(
          makerName: maker.firstName,
          current: step,
          sentAt: r.sentAt,
          middleDetail: r.stage == RequestStage.awaitingMaker
              ? _Countdown(request: r, now: now)
              : r.confirmedAt == null
                  ? null
                  : Text('Confirmed ${when(r.confirmedAt!)}. Checked in person and held for you.', style: t.bodySmall),
        ),
        const SizedBox(height: 28),
        if (r.stage == RequestStage.awaitingMaker) ...[
          _WhyWeWait(maker: maker),
          const SizedBox(height: 24),
          _DemoControls(request: r),
        ],
        if (r.stage == RequestStage.confirmed) ...[
          const SectionLabel('Summary'),
          GroupCard(children: [
            SpecRow(label: 'Piece', value: usd(r.piece.priceUsd)),
            SpecRow(
              label: 'Shipping',
              value: usd(r.shipping),
              note: r.piece.large ? 'Insured, crated, white-glove delivery' : 'Insured, signed for',
            ),
            SpecRow(label: 'Total', value: usd(r.total), emphasis: true),
          ]),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _paying ? null : _pay,
            child: _paying
                ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 1.6, color: c.onPrimary))
                : Text('Finalise payment  ·  ${usd(r.total)}'),
          ),
          const SizedBox(height: 10),
          Text('Demo: no card is charged.', style: t.bodySmall, textAlign: TextAlign.center),
        ],
        if (r.note.isNotEmpty) ...[
          const SizedBox(height: 32),
          const SectionLabel('Your message'),
          Text('“${r.note}”', style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: c.onSurfaceVariant)),
        ],
      ]),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({required this.request, required this.now});
  final OrderRequest request;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('By ${when(request.confirmBy)}', style: t.bodySmall),
      const SizedBox(height: 10),
      ClipRect(
        child: LinearProgressIndicator(
          value: windowUsed(request, now),
          minHeight: 3,
          color: c.secondary,
          backgroundColor: c.outlineVariant,
        ),
      ),
      const SizedBox(height: 8),
      Text(timeLeft(request.confirmBy, now).toUpperCase(),
          style: t.labelSmall?.copyWith(color: c.secondary, letterSpacing: 1.1)),
    ]);
  }
}

class _WhyWeWait extends StatelessWidget {
  const _WhyWeWait({required this.maker});
  final Maker maker;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      color: c.surfaceContainerLow,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Why we wait ${kConfirmWindow.inHours} hours', style: t.titleLarge),
        const SizedBox(height: 10),
        Text(
          'Handmark pieces are not in a warehouse. ${maker.firstName} may be at a fair, mid-firing, or '
          'finishing the piece itself. We ask every maker to check the piece in person and confirm it '
          'is ready to ship before you pay, so nothing is ever sold twice and nothing is refunded later.',
          style: t.bodyMedium,
        ),
      ]),
    );
  }
}

/// DEMO ONLY: plays the maker's side so the whole flow can be clicked through.
class _DemoControls extends StatelessWidget {
  const _DemoControls({required this.request});
  final OrderRequest request;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final store = context.requests;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(border: Border.all(color: c.outline)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DEMO  ·  PLAY THE MAKER', style: t.labelSmall?.copyWith(color: c.onSurfaceVariant)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () => store.confirm(request), child: const Text('Confirm'))),
          const SizedBox(width: 10),
          Expanded(child: TextButton(onPressed: () => store.decline(request), child: const Text('Decline'))),
        ]),
      ]),
    );
  }
}

/// The Requests tab: everything the buyer has asked for, newest first.
class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key, required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final store = context.requests;
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final now = DateTime.now();
    String status(OrderRequest r) => switch (r.stage) {
          RequestStage.awaitingMaker => 'Awaiting maker  ·  ${timeLeft(r.confirmBy, now)}',
          RequestStage.confirmed => 'Confirmed  ·  ready for payment',
          RequestStage.paid => 'Purchased  ·  shipping soon',
          RequestStage.declined => 'Not available  ·  not charged',
        };

    return SafeArea(
      bottom: false,
      child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 40), children: [
        const PageHeader(
          eyebrow: 'Requests',
          title: 'Your requests',
          subtitle: 'Makers confirm each piece within 48 hours. You pay only after they do.',
        ),
        if (store.items.isEmpty) ...[
          const SizedBox(height: 24),
          Text('Nothing requested yet.', style: t.titleLarge),
          const SizedBox(height: 8),
          Text('When you request a piece, it is held for you while the maker confirms.',
              style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant)),
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerLeft, child: OutlinedButton(onPressed: onBrowse, child: const Text('Browse the collection'))),
        ] else
          GroupCard(children: [
            for (final r in store.items)
              RowTile(
                leading: RequestThumb(r),
                title: r.piece.title,
                subtitle: status(r),
                onTap: () => openRequest(context, r),
              ),
          ]),
      ]),
    );
  }
}
