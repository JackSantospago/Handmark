import 'package:flutter/material.dart';

import '../../core/catalog.dart';
import '../../core/config.dart';
import '../../core/requests.dart';
import '../shared/piece_image.dart';
import '../shared/ui.dart';
import 'request_status_screen.dart';

/// Step 1 of 3: the buyer sends a request. Nothing is charged here; the maker
/// first confirms the piece is available (within 48 hours), then the buyer pays.
class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key, required this.piece});
  final Piece piece;

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _note = TextEditingController();
  final _shipTo = TextEditingController(text: 'Italy');

  @override
  void dispose() {
    _note.dispose();
    _shipTo.dispose();
    super.dispose();
  }

  void _send() {
    final r = context.requests.submit(widget.piece, note: _note.text.trim(), shipTo: _shipTo.text.trim());
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => RequestStatusScreen(request: r)));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final piece = widget.piece;
    final maker = context.catalog.makerOf(piece);

    return Scaffold(
      appBar: AppBar(title: const Text('REQUEST')),
      body: ListView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 32), children: [
        Row(children: [
          SizedBox(width: 76, child: PieceImage(piece, hero: false)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(piece.title, style: t.titleMedium),
              const SizedBox(height: 2),
              Text(maker.name, style: t.bodySmall),
              const SizedBox(height: 8),
              Text(usd(piece.priceUsd), style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ]),
          ),
        ]),
        const SizedBox(height: 36),
        Text('Request this piece', style: t.headlineMedium),
        const SizedBox(height: 10),
        Text(
          'Every piece on Handmark exists once, in a working studio. Before any money moves, '
          '${maker.firstName} confirms it is still available and ready to ship.',
          style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        const SectionLabel('How it works'),
        RequestSteps(makerName: maker.firstName, current: 0),
        const SizedBox(height: 32),
        const SectionLabel('Your request'),
        TextField(
          controller: _note,
          minLines: 3,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Message to ${maker.firstName} (optional)',
            alignLabelWithHint: true,
            hintText: 'Questions about the piece, timing, or delivery',
          ),
        ),
        const SizedBox(height: 14),
        TextField(controller: _shipTo, decoration: const InputDecoration(labelText: 'Deliver to (country)')),
        const SizedBox(height: 28),
        FilledButton(onPressed: _send, child: const Text('Send request')),
        const SizedBox(height: 10),
        Text(
          'You will not be charged now. If ${maker.firstName} cannot confirm within '
          '${kConfirmWindow.inHours} hours, the request simply lapses.',
          style: t.bodySmall,
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

/// The three steps, with the 48-hour maker confirmation in the middle.
/// [current]: 0 = about to send, 1 = waiting for the maker, 2 = ready to pay, 3 = done.
class RequestSteps extends StatelessWidget {
  const RequestSteps({super.key, required this.makerName, required this.current, this.middleDetail, this.sentAt});
  final String makerName;
  final int current;

  /// Replaces the middle step's description (e.g. the live countdown).
  final Widget? middleDetail;

  /// When the request went out (null = not sent yet).
  final DateTime? sentAt;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('You send a request', '${sentAt == null ? 'Today' : 'Sent ${when(sentAt!)}'}. No payment, no commitment.'),
      ('$makerName confirms availability', 'Within ${kConfirmWindow.inHours} hours. The piece is held for you meanwhile.'),
      ('You finalise payment', 'Only after confirmation. Insured shipping within $kShipWithinDays days.'),
    ];
    return Column(children: [
      for (var i = 0; i < steps.length; i++)
        _Step(
          index: i,
          title: steps[i].$1,
          detail: i == 1 && middleDetail != null ? middleDetail! : Text(steps[i].$2, style: Theme.of(context).textTheme.bodySmall),
          state: i < current ? _StepState.done : (i == current ? _StepState.active : _StepState.todo),
          last: i == steps.length - 1,
          highlight: i == 1,
        ),
    ]);
  }
}

enum _StepState { done, active, todo }

class _Step extends StatelessWidget {
  const _Step({
    required this.index,
    required this.title,
    required this.detail,
    required this.state,
    required this.last,
    required this.highlight,
  });
  final int index;
  final String title;
  final Widget detail;
  final _StepState state;
  final bool last, highlight;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;
    final filled = state != _StepState.todo;
    final accent = highlight ? c.secondary : c.onSurface;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 28,
          child: Column(children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: state == _StepState.done ? c.onSurface : Colors.transparent,
                border: Border.all(color: filled ? (state == _StepState.active ? accent : c.onSurface) : c.outline, width: 1.2),
              ),
              child: state == _StepState.done
                  ? Icon(Icons.check, size: 14, color: c.surface)
                  : Text('${index + 1}',
                      style: t.labelMedium?.copyWith(color: state == _StepState.active ? accent : c.onSurfaceVariant)),
            ),
            if (!last) Expanded(child: Container(width: 1, color: state == _StepState.done ? c.onSurface : c.outline)),
          ]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 3, bottom: last ? 0 : 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.titleMedium?.copyWith(color: state == _StepState.todo ? c.onSurfaceVariant : c.onSurface)),
              const SizedBox(height: 4),
              detail,
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Small-caps label + piece thumb used by the status page and the Requests tab.
class RequestThumb extends StatelessWidget {
  const RequestThumb(this.request, {super.key, this.size = 56});
  final OrderRequest request;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(width: size, child: PieceImage(request.piece, hero: false));
}

/// Hours and minutes left, e.g. "28 h 40 min left".
String timeLeft(DateTime until, DateTime now) {
  final d = until.difference(now);
  if (d.isNegative) return 'Window closed';
  final h = d.inHours, m = d.inMinutes % 60;
  return h > 0 ? '$h h ${m.toString().padLeft(2, '0')} min left' : '$m min left';
}

/// Fraction of the confirmation window already used.
double windowUsed(OrderRequest r, DateTime now) =>
    (now.difference(r.sentAt).inSeconds / kConfirmWindow.inSeconds).clamp(0.0, 1.0);

/// The shared time format, re-exported for request screens.
String when(DateTime d) => shortDateTime(d);
