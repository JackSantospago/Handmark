import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/catalog.dart';

/// PLACEHOLDER PHOTOGRAPHY. Until real studio photos exist, each piece is drawn
/// as a quiet still life: a seamless paper backdrop, a soft floor shadow and a
/// simple silhouette of the object in its own colour. Nothing is fetched, so
/// the demo looks the same offline and on GitHub Pages.
class PieceImage extends StatelessWidget {
  const PieceImage(this.piece, {super.key, this.aspectRatio = 4 / 5, this.hero = true});
  final Piece piece;
  final double aspectRatio;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final img = AspectRatio(
      aspectRatio: aspectRatio,
      child: CustomPaint(painter: _StillLife(piece.kind, piece.backdrop, piece.object), child: const SizedBox.expand()),
    );
    return hero ? Hero(tag: 'piece-${piece.id}', child: img) : img;
  }
}

/// PLACEHOLDER PORTRAIT: a toned card with the maker's initials in the serif.
class MakerPortrait extends StatelessWidget {
  const MakerPortrait(this.maker, {super.key, this.aspectRatio = 4 / 5, this.size});
  final Maker maker;
  final double aspectRatio;

  /// Fixed square size (thumbnails); null fills the width at [aspectRatio].
  final double? size;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final box = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(maker.tone, Colors.white, 0.18)!, Color.lerp(maker.tone, Colors.black, 0.25)!],
        ),
      ),
      child: Center(
        child: Text(
          maker.initials,
          style: t.displaySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: size != null ? size! * 0.36 : 64,
            letterSpacing: 1,
          ),
        ),
      ),
    );
    if (size != null) return SizedBox.square(dimension: size, child: box);
    return AspectRatio(aspectRatio: aspectRatio, child: box);
  }
}

class _StillLife extends CustomPainter {
  _StillLife(this.kind, this.bg, this.ink);
  final PieceKind kind;
  final Color bg, ink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final floorY = h * 0.74;
    final rect = Offset.zero & size;

    // Seamless paper: lighter at the top, a soft sweep into the floor.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(bg, Colors.white, 0.35)!, bg, Color.lerp(bg, Colors.black, 0.06)!],
          stops: const [0, 0.7, 1],
        ).createShader(rect),
    );
    // Side light from the left.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.8, -0.6),
          radius: 1.2,
          colors: [Colors.white.withValues(alpha: 0.22), Colors.transparent],
        ).createShader(rect),
    );

    final s = math.min(w, h * 0.8); // object scale
    final cx = w / 2;

    if (kind == PieceKind.canvas) {
      _painting(canvas, w, h, s);
      return;
    }

    // Contact shadow on the floor.
    final shadowW = switch (kind) {
      PieceKind.chair || PieceKind.sideTable => s * 0.62,
      PieceKind.moonJar || PieceKind.bowl => s * 0.6,
      PieceKind.decanter => s * 0.3,
      _ => s * 0.34,
    };
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + s * 0.03, floorY), width: shadowW, height: s * 0.07),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.025),
    );

    final body = Paint()
      ..shader = LinearGradient(
        colors: [Color.lerp(ink, Colors.white, 0.22)!, ink, Color.lerp(ink, Colors.black, 0.3)!],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCenter(center: Offset(cx, floorY - s * 0.3), width: s * 0.7, height: s * 0.6));

    switch (kind) {
      case PieceKind.chair:
        _chair(canvas, cx, floorY, s, body);
      case PieceKind.sideTable:
        _table(canvas, cx, floorY, s, body);
      case PieceKind.decanter:
        _decanter(canvas, cx, floorY, s);
      case PieceKind.moonJar:
        _moonJar(canvas, cx, floorY, s, body);
      case PieceKind.ring:
        _ring(canvas, cx, floorY, s);
      case PieceKind.pendant:
        _pendant(canvas, cx, floorY, s);
      case PieceKind.bowl:
        _bowl(canvas, cx, floorY, s, body);
      case PieceKind.canvas:
        break;
    }
  }

  Paint get _dark => Paint()..color = Color.lerp(ink, Colors.black, 0.35)!;

  void _chair(Canvas c, double cx, double fy, double s, Paint body) {
    final leg = _dark;
    final seatY = fy - s * 0.24;
    // Back legs (thinner, behind).
    c.drawRect(Rect.fromLTWH(cx - s * 0.2, seatY - s * 0.02, s * 0.022, s * 0.24), leg);
    c.drawRect(Rect.fromLTWH(cx + s * 0.19, seatY - s * 0.02, s * 0.022, s * 0.24), leg);
    // Leaning backrest.
    final back = Path()
      ..moveTo(cx - s * 0.23, seatY - s * 0.02)
      ..lineTo(cx - s * 0.27, seatY - s * 0.36)
      ..quadraticBezierTo(cx, seatY - s * 0.4, cx + s * 0.27, seatY - s * 0.36)
      ..lineTo(cx + s * 0.23, seatY - s * 0.02)
      ..close();
    c.drawPath(back, body);
    // Sling seat.
    final seat = Path()
      ..moveTo(cx - s * 0.29, seatY - s * 0.04)
      ..quadraticBezierTo(cx, seatY + s * 0.06, cx + s * 0.29, seatY - s * 0.04)
      ..lineTo(cx + s * 0.29, seatY + s * 0.02)
      ..quadraticBezierTo(cx, seatY + s * 0.11, cx - s * 0.29, seatY + s * 0.02)
      ..close();
    c.drawPath(seat, Paint()..color = Color.lerp(ink, Colors.black, 0.15)!);
    // Front legs, splayed.
    for (final dir in [-1.0, 1.0]) {
      final p = Path()
        ..moveTo(cx + dir * s * 0.26, seatY)
        ..lineTo(cx + dir * s * 0.29, fy)
        ..lineTo(cx + dir * s * 0.26, fy)
        ..lineTo(cx + dir * s * 0.235, seatY)
        ..close();
      c.drawPath(p, leg);
    }
    // Arm rails.
    for (final dir in [-1.0, 1.0]) {
      c.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(cx + (dir < 0 ? -s * 0.31 : s * 0.24), seatY - s * 0.12, s * 0.07, s * 0.022), Radius.circular(s * 0.01)),
        leg,
      );
    }
  }

  void _table(Canvas c, double cx, double fy, double s, Paint body) {
    final topY = fy - s * 0.42;
    c.drawOval(Rect.fromCenter(center: Offset(cx, fy - s * 0.01), width: s * 0.3, height: s * 0.05), _dark);
    final col = Path()
      ..moveTo(cx - s * 0.05, topY + s * 0.04)
      ..lineTo(cx - s * 0.07, fy - s * 0.01)
      ..lineTo(cx + s * 0.07, fy - s * 0.01)
      ..lineTo(cx + s * 0.05, topY + s * 0.04)
      ..close();
    c.drawPath(col, body);
    c.drawRect(Rect.fromLTWH(cx - s * 0.3, topY, s * 0.6, s * 0.06), body);
    c.drawOval(Rect.fromCenter(center: Offset(cx, topY), width: s * 0.6, height: s * 0.07),
        Paint()..color = Color.lerp(ink, Colors.white, 0.18)!);
  }

  void _decanter(Canvas c, double cx, double fy, double s) {
    final glass = Paint()..color = ink.withValues(alpha: 0.55);
    final r = s * 0.13;
    final bodyC = Offset(cx, fy - r - s * 0.01);
    final p = Path()
      ..addOval(Rect.fromCircle(center: bodyC, radius: r))
      ..addRect(Rect.fromLTWH(cx - s * 0.03, fy - s * 0.47, s * 0.06, s * 0.24));
    c.drawPath(p, glass);
    // Lip and stopper.
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, fy - s * 0.47), width: s * 0.085, height: s * 0.018),
        Radius.circular(s * 0.01)), glass);
    c.drawCircle(Offset(cx, fy - s * 0.51), s * 0.032, Paint()..color = ink.withValues(alpha: 0.7));
    // Liquid line and highlights.
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: bodyC, radius: r)));
    c.drawRect(Rect.fromLTWH(cx - r, bodyC.dy + r * 0.1, 2 * r, r), Paint()..color = ink.withValues(alpha: 0.35));
    c.restore();
    final hi = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.008
      ..strokeCap = StrokeCap.round;
    c.drawArc(Rect.fromCircle(center: bodyC, radius: r * 0.78), math.pi * 1.05, math.pi * 0.4, false, hi);
    c.drawLine(Offset(cx - s * 0.015, fy - s * 0.44), Offset(cx - s * 0.015, fy - s * 0.27), hi);
  }

  void _moonJar(Canvas c, double cx, double fy, double s, Paint body) {
    final r = s * 0.27;
    final center = Offset(cx, fy - r * 1.02);
    c.drawRect(Rect.fromCenter(center: Offset(cx, fy - s * 0.015), width: s * 0.2, height: s * 0.03), _dark);
    c.drawOval(Rect.fromCenter(center: center, width: r * 2.04, height: r * 1.96), body);
    c.drawRect(Rect.fromCenter(center: Offset(cx, center.dy - r * 0.98), width: s * 0.18, height: s * 0.035), body);
    // Ash-glaze run down one side.
    c.drawOval(
      Rect.fromCenter(center: center.translate(r * 0.45, -r * 0.1), width: r * 0.35, height: r * 1.3),
      Paint()
        ..color = const Color(0xFF8E9A7A).withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.03),
    );
  }

  void _ring(Canvas c, double cx, double fy, double s) {
    // Small plinth.
    final plinth = Rect.fromLTWH(cx - s * 0.17, fy - s * 0.16, s * 0.34, s * 0.16);
    c.drawRect(plinth, Paint()..color = Color.lerp(bg, Colors.white, 0.4)!);
    c.drawRect(Rect.fromLTWH(plinth.left, plinth.top, plinth.width, s * 0.012), Paint()..color = Color.lerp(bg, Colors.white, 0.6)!);
    final metal = Paint()
      ..shader = LinearGradient(colors: [Color.lerp(ink, Colors.white, 0.45)!, ink, Color.lerp(ink, Colors.black, 0.35)!])
          .createShader(Rect.fromCircle(center: Offset(cx, fy - s * 0.27), radius: s * 0.1))
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.03;
    c.drawOval(Rect.fromCenter(center: Offset(cx, fy - s * 0.25), width: s * 0.17, height: s * 0.18), metal);
    c.drawOval(Rect.fromCenter(center: Offset(cx, fy - s * 0.345), width: s * 0.11, height: s * 0.05),
        Paint()..color = Color.lerp(ink, Colors.white, 0.2)!);
  }

  void _pendant(Canvas c, double cx, double fy, double s) {
    final chain = Paint()
      ..color = Color.lerp(ink, Colors.black, 0.15)!
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.006;
    final top = fy - s * 0.6;
    final dropY = fy - s * 0.22;
    c.drawPath(
        Path()
          ..moveTo(cx - s * 0.2, top)
          ..quadraticBezierTo(cx - s * 0.08, dropY - s * 0.02, cx, dropY - s * 0.05)
          ..quadraticBezierTo(cx + s * 0.08, dropY - s * 0.02, cx + s * 0.2, top),
        chain);
    final drop = Path()
      ..moveTo(cx, dropY - s * 0.05)
      ..cubicTo(cx + s * 0.07, dropY + s * 0.02, cx + s * 0.06, dropY + s * 0.1, cx, dropY + s * 0.11)
      ..cubicTo(cx - s * 0.06, dropY + s * 0.1, cx - s * 0.07, dropY + s * 0.02, cx, dropY - s * 0.05);
    c.drawPath(
      drop,
      Paint()
        ..shader = LinearGradient(colors: [Colors.white, ink, Color.lerp(ink, Colors.black, 0.3)!])
            .createShader(Rect.fromCenter(center: Offset(cx, dropY + s * 0.03), width: s * 0.14, height: s * 0.16)),
    );
    c.drawOval(Rect.fromCenter(center: Offset(cx, fy - s * 0.002), width: s * 0.1, height: s * 0.016),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.01));
  }

  void _bowl(Canvas c, double cx, double fy, double s, Paint body) {
    final rimY = fy - s * 0.17;
    final bowl = Path()
      ..moveTo(cx - s * 0.3, rimY)
      ..quadraticBezierTo(cx - s * 0.27, fy - s * 0.01, cx - s * 0.08, fy - s * 0.005)
      ..lineTo(cx + s * 0.08, fy - s * 0.005)
      ..quadraticBezierTo(cx + s * 0.27, fy - s * 0.01, cx + s * 0.3, rimY)
      ..close();
    c.drawPath(bowl, body);
    final rim = Rect.fromCenter(center: Offset(cx, rimY), width: s * 0.6, height: s * 0.09);
    c.drawOval(rim, Paint()..color = Color.lerp(ink, Colors.white, 0.25)!);
    c.drawOval(rim.deflate(s * 0.014), Paint()..color = Color.lerp(ink, Colors.black, 0.2)!);
    // Grain lines.
    final grain = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.004;
    for (var i = 1; i <= 3; i++) {
      c.drawArc(Rect.fromCenter(center: Offset(cx, rimY), width: s * (0.6 - i * 0.04), height: s * (0.22 + i * 0.03)),
          0.25, math.pi - 0.5, false, grain);
    }
  }

  void _painting(Canvas c, double w, double h, double s) {
    final pw = w * 0.7, ph = pw * 0.75;
    final r = Rect.fromCenter(center: Offset(w / 2, h * 0.42), width: pw, height: ph);
    c.drawRect(r.shift(Offset(s * 0.012, s * 0.02)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.02));
    // Landscape bands: sky, rose, marsh, water.
    final bands = [
      (0.0, 0.42, const Color(0xFFD8CFC0)),
      (0.42, 0.52, const Color(0xFFD9B8A8)),
      (0.52, 0.78, ink),
      (0.78, 1.0, const Color(0xFF7E8673)),
    ];
    for (final (a, b, col) in bands) {
      c.drawRect(Rect.fromLTRB(r.left, r.top + ph * a, r.right, r.top + ph * b), Paint()..color = col);
    }
    c.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.12), Colors.transparent, Colors.black.withValues(alpha: 0.12)],
        ).createShader(r),
    );
    // Canvas edge.
    c.drawRect(r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.15));
  }

  @override
  bool shouldRepaint(_StillLife old) => old.kind != kind || old.bg != bg || old.ink != ink;
}
