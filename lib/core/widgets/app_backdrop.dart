import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Fondo global estilo "Jules" pero en azul/cyan: degradado oscuro de base más
/// un campo de píxeles (rejilla de puntos tenue + cuadros y signos "+"
/// dispersos). El patrón disperso es determinista, así no parpadea al repintar.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.4, -0.6),
          radius: 1.4,
          colors: [
            Color(0xFF141430),
            Color(0xFF0A0A0F),
          ],
          stops: [0.0, 0.85],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _PixelFieldPainter()),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Pinta un campo de píxeles tipo 8-bit: rejilla de puntos + motivos dispersos
/// (cuadros y signos "+") en cyan y azul, a baja opacidad.
class _PixelFieldPainter extends CustomPainter {
  // Separación de la rejilla base de puntos.
  static const double _dotStep = 26;
  // Tamaño de celda para los motivos dispersos.
  static const double _cell = 48;
  // Azul para variar respecto al cyan del acento.
  static const Color _blue = Color(0xFF2F6BFF);

  /// Hash determinista por celda → patrón disperso estable.
  int _hash(int x, int y) {
    var h = (x * 73856093) ^ (y * 19349663);
    return h & 0x7fffffff;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Rejilla base de puntos muy tenue.
    final dotPaint = Paint()
      ..color = AppColors.primaryAccent.withValues(alpha: 0.05);
    for (double y = 0; y <= size.height; y += _dotStep) {
      for (double x = 0; x <= size.width; x += _dotStep) {
        canvas.drawRect(Rect.fromLTWH(x, y, 2, 2), dotPaint);
      }
    }

    // 2) Motivos dispersos deterministas (cuadros y signos "+").
    final cols = (size.width / _cell).ceil();
    final rows = (size.height / _cell).ceil();
    for (int j = 0; j < rows; j++) {
      for (int i = 0; i < cols; i++) {
        final h = _hash(i + 1, j + 1);
        final kind = h % 9; // 0..8
        if (kind > 3) continue; // ~44% de celdas con motivo

        // Posición dentro de la celda (con margen para no tocar el borde).
        final px = i * _cell + ((h >> 3) % 36) + 4;
        final py = j * _cell + ((h >> 11) % 36) + 4;

        final bright = (h >> 17) % 5 == 0;
        final color = ((h >> 19) % 4 == 0 ? _blue : AppColors.primaryAccent)
            .withValues(alpha: bright ? 0.16 : 0.07);
        final paint = Paint()..color = color;

        switch (kind) {
          case 0: // cuadro pequeño
            canvas.drawRect(Rect.fromLTWH(px, py, 4, 4), paint);
            break;
          case 1: // cuadro mediano
            canvas.drawRect(Rect.fromLTWH(px, py, 7, 7), paint);
            break;
          case 2: // signo "+"
            canvas.drawRect(Rect.fromLTWH(px, py + 3, 8, 2), paint);
            canvas.drawRect(Rect.fromLTWH(px + 3, py, 2, 8), paint);
            break;
          case 3: // par de píxeles en diagonal
            canvas.drawRect(Rect.fromLTWH(px, py, 3, 3), paint);
            canvas.drawRect(Rect.fromLTWH(px + 5, py + 5, 3, 3), paint);
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
