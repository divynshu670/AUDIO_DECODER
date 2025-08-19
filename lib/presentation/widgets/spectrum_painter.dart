import 'package:flutter/material.dart';

class ChunkSpectrum extends StatelessWidget {
  final List<double> freqs; // Hz per chunk
  const ChunkSpectrum({super.key, required this.freqs});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 100),
      painter: _SpectrumPainter(freqs),
    );
  }
}

class _SpectrumPainter extends CustomPainter {
  final List<double> f;
  _SpectrumPainter(this.f);

  @override
  void paint(Canvas canvas, Size size) {
    if (f.isEmpty) return;
    final maxHz = f.reduce((a, b) => a > b ? a : b).clamp(1, 1000);
    final barW = (size.width / f.length).clamp(1, 12.0);
    final paint = Paint();

    for (int i = 0; i < f.length; i++) {
      final h = (f[i] / maxHz) * size.height;
      final x = i * barW;
      final rect = Rect.fromLTWH(x.toDouble(), size.height - h, barW * 0.8, h);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpectrumPainter oldDelegate) => false;
}
