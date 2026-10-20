import 'package:flutter/widgets.dart';

import 'catalog.dart';
import 'config.dart';

/// Request → the maker confirms availability (within [kConfirmWindow]) →
/// the buyer finalises payment. Nothing is charged before confirmation.
enum RequestStage { awaitingMaker, confirmed, paid, declined }

class OrderRequest {
  OrderRequest({required this.id, required this.piece, required this.sentAt, this.note = '', this.shipTo = ''});
  final String id;
  final Piece piece;
  final DateTime sentAt;
  final String note, shipTo;
  RequestStage stage = RequestStage.awaitingMaker;
  DateTime? confirmedAt, paidAt;

  DateTime get confirmBy => sentAt.add(kConfirmWindow);
  int get shipping => piece.large ? kShippingLarge : kShippingSmall;
  int get total => piece.priceUsd + shipping;
}

/// The buyer's requests, in memory (a real app would sync them).
class RequestStore extends ChangeNotifier {
  final List<OrderRequest> items = [];
  int _next = 1;

  OrderRequest submit(Piece piece, {String note = '', String shipTo = '', DateTime? at}) {
    final r = OrderRequest(id: 'R-${1040 + _next++}', piece: piece, sentAt: at ?? DateTime.now(), note: note, shipTo: shipTo);
    items.insert(0, r);
    notifyListeners();
    return r;
  }

  OrderRequest? openFor(Piece piece) => items
      .where((r) => r.piece.id == piece.id && r.stage != RequestStage.declined)
      .firstOrNull;

  void confirm(OrderRequest r) => _set(r, RequestStage.confirmed, () => r.confirmedAt = DateTime.now());
  void decline(OrderRequest r) => _set(r, RequestStage.declined, () {});
  void pay(OrderRequest r) => _set(r, RequestStage.paid, () => r.paidAt = DateTime.now());

  void _set(OrderRequest r, RequestStage s, VoidCallback also) {
    r.stage = s;
    also();
    notifyListeners();
  }
}

/// Catalog and requests for everything below it.
class HandmarkScope extends InheritedNotifier<RequestStore> {
  const HandmarkScope({super.key, required this.catalog, required RequestStore requests, required super.child})
      : super(notifier: requests);
  final Catalog catalog;

  static HandmarkScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<HandmarkScope>()!;
}

extension HandmarkContext on BuildContext {
  Catalog get catalog => HandmarkScope.of(this).catalog;
  RequestStore get requests => HandmarkScope.of(this).notifier!;
}
