import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Draws the Recollia iris — radial spokes over an amber-to-deep-red gradient,
/// six concentric rings, one upward-pointing ivory spoke, and a large black pupil.
///
/// [progress] 0 → 1 controls the draw-on animation (spokes appear radially,
/// rings fade in in sequence, pupil resolves last).
/// [alpha] multiplies every colour's opacity for fade-in/out use.
class IrisPainter extends CustomPainter {
  final double progress;
  final double alpha;

  const IrisPainter({this.progress = 1.0, this.alpha = 1.0});

  // ── Normalised radii of the six concentric rings (iris radius = 1.0) ──
  static const _ringFractions = [0.929, 0.845, 0.726, 0.607, 0.500, 0.411];
  static const _ringColors = [
    Color(0xFFE89A4D), Color(0xFFE89A4D),
    Color(0xFFB84A08), Color(0xFFB84A08),
    Color(0xFF7A1500), Color(0xFF7A1500),
  ];
  static const _ringOpacities  = [0.17, 0.21, 0.27, 0.31, 0.37, 0.45];
  static const _ringStrokeW    = [1.0,  1.0,  1.0,  1.0,  1.0,  1.2 ];
  // The scroll threshold at which each ring begins to draw
  static const _ringThresholds = [0.28, 0.36, 0.44, 0.52, 0.58, 0.64];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || alpha <= 0) return;

    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = math.min(size.width, size.height) / 2;
    final c  = Offset(cx, cy);

    // ── Outer halo rings (beyond the iris, drawn before clip) ─────────────
    if (progress > 0.5) {
      final ha = ((progress - 0.5) / 0.5).clamp(0.0, 1.0) * alpha;
      _strokeCircle(canvas, c, r * 1.143,
          const Color(0xFF7A1500).withValues(alpha:0.14 * ha), 1.0);
      _strokeCircle(canvas, c, r * 1.071,
          const Color(0xFF7A1500).withValues(alpha:0.09 * ha), 1.0);
    }

    // ── Clip everything below to the iris circle ───────────────────────────
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));

    // Iris body gradient
    final irisRect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c, r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF7A1500).withValues(alpha:0.96 * alpha),
            const Color(0xFFB84A08).withValues(alpha:0.91 * alpha),
            const Color(0xFFE89A4D).withValues(alpha:0.80 * alpha),
            const Color(0xFF1E0A00).withValues(alpha:0.65 * alpha),
          ],
          stops: const [0.0, 0.25, 0.55, 1.0],
        ).createShader(irisRect),
    );

    // ── 72 radial spokes ───────────────────────────────────────────────────
    final spokesToDraw = (progress * 72).ceil().clamp(0, 72);
    for (int i = 0; i < spokesToDraw; i++) {
      final deg = i * 5;
      final rad = deg * math.pi / 180.0;
      Color col;
      double sw, opa;
      if (deg % 45 == 0) {
        col = const Color(0xFFE89A4D); sw = 0.65; opa = 0.42;
      } else if (deg % 15 == 0) {
        col = const Color(0xFFB84A08); sw = 0.45; opa = 0.28;
      } else if (i % 3 == 0) {
        col = const Color(0xFF7A1500); sw = 0.38; opa = 0.20;
      } else {
        col = const Color(0xFF460A00); sw = 0.30; opa = 0.11;
      }
      canvas.drawLine(
        c,
        Offset(cx + r * math.cos(rad), cy + r * math.sin(rad)),
        Paint()
          ..color       = col.withValues(alpha:opa * alpha)
          ..strokeWidth = sw,
      );
    }

    // ── One ivory spoke pointing straight UP (−90° / 270°) ────────────────
    final wa = ((progress - 0.78) / 0.22).clamp(0.0, 1.0) * 0.90 * alpha;
    if (wa > 0) {
      canvas.drawLine(
        c,
        Offset(cx, cy - r),
        Paint()
          ..color       = RC.ivory.withValues(alpha:wa)
          ..strokeWidth = 1.0,
      );
    }

    // ── Concentric rings ───────────────────────────────────────────────────
    for (int i = 0; i < _ringFractions.length; i++) {
      final ra = ((progress - _ringThresholds[i]) / 0.14).clamp(0.0, 1.0);
      if (ra <= 0) continue;
      _strokeCircle(
        canvas, c, r * _ringFractions[i],
        _ringColors[i].withValues(alpha:_ringOpacities[i] * ra * alpha),
        _ringStrokeW[i],
      );
    }

    // ── Pupil ──────────────────────────────────────────────────────────────
    final pa = ((progress - 0.52) / 0.28).clamp(0.0, 1.0) * alpha;
    if (pa > 0) {
      canvas.drawCircle(
        c, r * 0.369,
        Paint()..color = const Color(0xFF060302).withValues(alpha:pa),
      );
      canvas.drawCircle(
        c, r * 0.333,
        Paint()..color = Colors.black.withValues(alpha:pa),
      );
      // Subtle specular highlight
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx - r * 0.115, cy - r * 0.09),
          width:  r * 0.082,
          height: r * 0.050,
        ),
        Paint()..color = RC.ivory.withValues(alpha:0.07 * pa * alpha),
      );
    }

    canvas.restore();
  }

  static void _strokeCircle(
      Canvas canvas, Offset center, double radius, Color color, double sw) {
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color       = color
        ..style       = PaintingStyle.stroke
        ..strokeWidth = sw,
    );
  }

  @override
  bool shouldRepaint(IrisPainter old) =>
      old.progress != progress || old.alpha != alpha;
}
