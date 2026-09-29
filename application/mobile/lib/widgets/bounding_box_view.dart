import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/detection.dart';

class BoundingBoxView extends StatelessWidget {
  const BoundingBoxView({
    super.key,
    required this.bytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.detections,
  });

  final Uint8List bytes;
  final int imageWidth;
  final int imageHeight;
  final List<Detection> detections;

  @override
  Widget build(BuildContext context) {
    final ratio = imageHeight == 0 ? 1.0 : imageWidth / imageHeight;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: ratio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(bytes, fit: BoxFit.fill, gaplessPlayback: true),
            CustomPaint(
              painter: _DetectionPainter(
                detections: detections,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectionPainter extends CustomPainter {
  _DetectionPainter({
    required this.detections,
    required this.imageWidth,
    required this.imageHeight,
  });

  final List<Detection> detections;
  final int imageWidth;
  final int imageHeight;

  static const _colors = [
    Color(0xFF0F766E),
    Color(0xFFB45309),
    Color(0xFF1D4ED8),
    Color(0xFFBE123C),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (imageWidth == 0 || imageHeight == 0) return;
    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;
    for (var index = 0; index < detections.length; index++) {
      final box = detections[index].bbox;
      final low = detections[index].confidence < AppConfig.lowConfidenceThreshold;
      final color = low ? const Color(0xFFC2410C) : _colors[index % _colors.length];
      final rect = Rect.fromLTRB(
        box.x1 * scaleX,
        box.y1 * scaleY,
        box.x2 * scaleX,
        box.y2 * scaleY,
      );
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
      _drawIndex(canvas, rect, color, index + 1);
    }
  }

  void _drawIndex(Canvas canvas, Rect rect, Color color, int number) {
    const radius = 12.0;
    final center = Offset(rect.left + radius, rect.top + radius);
    canvas.drawCircle(center, radius, Paint()..color = color);
    final painter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _DetectionPainter oldDelegate) {
    return oldDelegate.detections != detections ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight;
  }
}
