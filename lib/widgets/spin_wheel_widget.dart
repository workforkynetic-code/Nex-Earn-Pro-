// File: lib/widgets/spin_wheel_widget.dart
// Kaam: Canvas se bana hua spin wheel — animation ke saath prizes dikhata hai
// Weighted random prizes pick karta hai

import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class SpinWheelWidget extends StatefulWidget {
  final Function(int prize) onSpinComplete;
  final bool canSpin;

  const SpinWheelWidget({
    super.key,
    required this.onSpinComplete,
    required this.canSpin,
  });

  @override
  State<SpinWheelWidget> createState() => _SpinWheelWidgetState();
}

class _SpinWheelWidgetState extends State<SpinWheelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;
  bool _isSpinning = false;
  int? _wonPrize;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || !widget.canSpin) return;

    // Weighted random prize pick karo
    final prizeIndex =
        Helpers.weightedRandomIndex(SpinPrizes.weights);
    final prize = SpinPrizes.prizes[prizeIndex];

    // Calculate target angle
    final segmentAngle = 2 * pi / SpinPrizes.prizes.length;
    // Wheel ko ghuma ke sahi segment pe laao
    final targetSegmentAngle =
        (SpinPrizes.prizes.length - prizeIndex) * segmentAngle - segmentAngle / 2;
    final extraRotations = 5 * 2 * pi; // 5 full rotations
    final targetAngle = _currentAngle + extraRotations + targetSegmentAngle;

    setState(() => _isSpinning = true);

    _animation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward(from: 0).then((_) {
      setState(() {
        _currentAngle = targetAngle % (2 * pi);
        _isSpinning = false;
        _wonPrize = prize;
      });
      widget.onSpinComplete(prize);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pointer (arrow at top)
        const Icon(Icons.arrow_drop_down,
            color: AppColors.gold, size: 40),

        // Wheel
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value,
              child: child,
            );
          },
          child: SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(
              painter: _WheelPainter(),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Spin button
        GestureDetector(
          onTap: widget.canSpin && !_isSpinning ? _spin : null,
          child: Container(
            width: 120,
            height: 48,
            decoration: BoxDecoration(
              gradient: widget.canSpin && !_isSpinning
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    )
                  : null,
              color: widget.canSpin && !_isSpinning
                  ? null
                  : AppColors.cardBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                _isSpinning
                    ? 'Spinning...'
                    : !widget.canSpin
                        ? 'No Spins'
                        : 'SPIN!',
                style: TextStyle(
                  color: widget.canSpin && !_isSpinning
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / SpinPrizes.prizes.length;

    for (int i = 0; i < SpinPrizes.prizes.length; i++) {
      final startAngle = i * segmentAngle - pi / 2;

      // Draw segment
      final paint = Paint()
        ..color = SpinPrizes.colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      // Segment border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      // Draw prize text
      final textAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.65;
      final textX = center.dx + textRadius * cos(textAngle);
      final textY = center.dy + textRadius * sin(textAngle);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${SpinPrizes.prizes[i]}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // Center circle
    final centerPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 20, centerPaint);

    final centerBorderPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 20, centerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
