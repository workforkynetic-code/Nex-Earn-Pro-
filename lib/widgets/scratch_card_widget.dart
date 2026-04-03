// File: lib/widgets/scratch_card_widget.dart
// Kaam: Finger se scratch karne wala card — prize reveal hota hai
// GestureDetector + CustomPainter se bana hai

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ScratchCardWidget extends StatefulWidget {
  final int prize;
  final VoidCallback onFullyScratch;

  const ScratchCardWidget({
    super.key,
    required this.prize,
    required this.onFullyScratch,
  });

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  final List<Offset> _scratchPoints = [];
  bool _isRevealed = false;
  double _scratchedPercent = 0;

  // Scratch layer track karne ke liye
  final List<Offset> _path = [];

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isRevealed) return;
    setState(() {
      _path.add(details.localPosition);
      _calculateScratchPercent();
    });
  }

  void _calculateScratchPercent() {
    // Simple estimation: unique points count
    if (_path.length > 150 && !_isRevealed) {
      _isRevealed = true;
      widget.onFullyScratch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Prize layer (underneath)
            _buildPrizeLayer(),

            // Scratch layer (on top)
            if (!_isRevealed)
              GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: CustomPaint(
                  painter: _ScratchPainter(scratchedPoints: _path),
                  size: const Size(260, 160),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeLayer() {
    return Container(
      width: 260,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1e1a35), Color(0xFF2d1f6e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            '+${widget.prize} Coins',
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Scratch Card Prize!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  final List<Offset> scratchedPoints;

  _ScratchPainter({required this.scratchedPoints});

  @override
  void paint(Canvas canvas, Size size) {
    // Silver scratch layer
    final bgPaint = Paint()
      ..color = const Color(0xFF9ca3af)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ),
      bgPaint,
    );

    // Scratch pattern (dots)
    final dotPaint = Paint()
      ..color = const Color(0xFF6b7280)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < size.width.toInt(); i += 10) {
      for (int j = 0; j < size.height.toInt(); j += 10) {
        canvas.drawCircle(Offset(i.toDouble(), j.toDouble()), 1, dotPaint);
      }
    }

    // "Scratch here" text
    final tp = TextPainter(
      text: const TextSpan(
        text: '✦ SCRATCH HERE ✦',
        style: TextStyle(
          color: Color(0xFF4b5563),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size.width);
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );

    // Erase scratched areas (blend mode)
    if (scratchedPoints.isNotEmpty) {
      final erasePaint = Paint()
        ..blendMode = BlendMode.clear
        ..strokeWidth = 40
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(scratchedPoints.first.dx, scratchedPoints.first.dy);
      for (final point in scratchedPoints) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, erasePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScratchPainter oldDelegate) =>
      oldDelegate.scratchedPoints.length != scratchedPoints.length;
}
