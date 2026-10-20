import 'package:flutter/widgets.dart';

/// What a placeholder photo draws (see frontend/shared/piece_image.dart).
enum PieceKind { chair, sideTable, decanter, moonJar, canvas, ring, pendant, bowl }

enum Category {
  furniture('Furniture'),
  glass('Glass'),
  ceramics('Ceramics'),
  art('Art'),
  jewellery('Jewellery'),
  wood('Wood');

  const Category(this.label);
  final String label;
}

class Maker {
  const Maker({
    required this.id,
    required this.name,
    required this.craft,
    required this.workshop,
    required this.location,
    required this.since,
    required this.story,
    required this.quote,
    required this.tone,
  });
  final String id, name, craft, workshop, location, quote;
  final int since;

  /// Paragraphs.
  final List<String> story;

  /// Background of the placeholder portrait.
  final Color tone;

  String get initials => name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join();
  String get firstName => name.split(' ').first;
}

/// One listing with its provenance record: who made it, from what, how, where,
/// how many hours of human work, and an honest line on machine involvement.
class Piece {
  const Piece({
    required this.id,
    required this.title,
    required this.makerId,
    required this.category,
    required this.kind,
    required this.priceUsd,
    required this.year,
    required this.dimensions,
    required this.materials,
    required this.method,
    required this.hours,
    required this.origin,
    required this.machineNote,
    required this.description,
    required this.verificationId,
    required this.verifiedHow,
    required this.backdrop,
    required this.object,
    this.large = false,
  });
  final String id, title, makerId, dimensions, method, origin, machineNote, description;
  final Category category;
  final PieceKind kind;
  final int priceUsd, year, hours;
  final List<String> materials;

  /// Handmark's own check, e.g. "HM-2026-0142" and "Workshop visit, March 2026".
  final String verificationId, verifiedHow;

  /// Colours of the placeholder photo.
  final Color backdrop, object;

  /// Ships crated (furniture), which changes the shipping line.
  final bool large;
}

class Catalog {
  Catalog({required this.makers, required this.pieces});
  final List<Maker> makers;
  final List<Piece> pieces;

  Maker maker(String id) => makers.firstWhere((m) => m.id == id);
  Piece? piece(String id) => pieces.where((p) => p.id == id).firstOrNull;
  Maker makerOf(Piece p) => maker(p.makerId);
  List<Piece> piecesBy(String makerId) => [for (final p in pieces) if (p.makerId == makerId) p];
}

/// $4,200
String usd(int v) => '\$${v.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}';
