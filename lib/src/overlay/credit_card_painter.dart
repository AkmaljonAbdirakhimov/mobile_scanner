import 'dart:math';

import 'package:flutter/material.dart';
import 'package:awesome_mobile_scanner/src/objects/credit_card.dart';

/// A custom painter that draws credit card detection overlays.
class CreditCardPainter extends CustomPainter {
  /// Creates a new [CreditCardPainter] instance.
  const CreditCardPainter({
    required this.creditCard,
    required this.boxFit,
    required this.cameraPreviewSize,
    required this.color,
    required this.style,
    required this.strokeWidth,
    required this.textPainter,
  });

  /// The credit card to draw an overlay for.
  final CreditCard creditCard;

  /// The [BoxFit] to use when painting the credit card box.
  final BoxFit boxFit;

  /// The size of the camera preview.
  final Size cameraPreviewSize;

  /// The color to use when painting the credit card box.
  final Color color;

  /// The style to use when painting the credit card box.
  final PaintingStyle style;

  /// The stroke width for the credit card box.
  final double strokeWidth;

  /// The text painter for drawing credit card information.
  final TextPainter textPainter;

  @override
  void paint(Canvas canvas, Size size) {
    if (creditCard.corners.isEmpty) return;

    final paint =
        Paint()
          ..color = color
          ..style = style
          ..strokeWidth = strokeWidth;

    // Calculate the bounding rectangle from corners
    final rect = _calculateBoundingRect(size);

    // Draw the bounding box
    canvas.drawRect(rect, paint);

    // Draw credit card information
    _drawCreditCardInfo(canvas, rect, paint);
  }

  /// Calculate the bounding rectangle for the credit card.
  Rect _calculateBoundingRect(Size size) {
    if (creditCard.corners.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (final corner in creditCard.corners) {
      minX = min(minX, corner.dx);
      minY = min(minY, corner.dy);
      maxX = max(maxX, corner.dx);
      maxY = max(maxY, corner.dy);
    }

    // Apply box fit transformations
    final transformedRect = _applyBoxFit(Rect.fromLTRB(minX, minY, maxX, maxY), size);

    return transformedRect;
  }

  /// Apply box fit transformations to the rectangle.
  Rect _applyBoxFit(Rect rect, Size size) {
    if (cameraPreviewSize.isEmpty || size.isEmpty) return rect;

    final scaleX = size.width / cameraPreviewSize.width;
    final scaleY = size.height / cameraPreviewSize.height;

    switch (boxFit) {
      case BoxFit.cover:
        final scale = max(scaleX, scaleY);
        final scaledWidth = cameraPreviewSize.width * scale;
        final scaledHeight = cameraPreviewSize.height * scale;
        final offsetX = (size.width - scaledWidth) / 2;
        final offsetY = (size.height - scaledHeight) / 2;

        return Rect.fromLTWH(
          rect.left * scale + offsetX,
          rect.top * scale + offsetY,
          rect.width * scale,
          rect.height * scale,
        );

      case BoxFit.contain:
        final scale = min(scaleX, scaleY);
        final scaledWidth = cameraPreviewSize.width * scale;
        final scaledHeight = cameraPreviewSize.height * scale;
        final offsetX = (size.width - scaledWidth) / 2;
        final offsetY = (size.height - scaledHeight) / 2;

        return Rect.fromLTWH(
          rect.left * scale + offsetX,
          rect.top * scale + offsetY,
          rect.width * scale,
          rect.height * scale,
        );

      case BoxFit.fill:
        return Rect.fromLTWH(rect.left * scaleX, rect.top * scaleY, rect.width * scaleX, rect.height * scaleY);

      default:
        return rect;
    }
  }

  /// Draw credit card information on the canvas.
  void _drawCreditCardInfo(Canvas canvas, Rect rect, Paint paint) {
    final info = <String>[];

    if (creditCard.maskedCardNumber != null) {
      info.add('Card: ${creditCard.maskedCardNumber}');
    }
    if (creditCard.expiryDate != null) {
      info.add('Exp: ${creditCard.expiryDate}');
    }
    if (creditCard.cardholderName != null) {
      info.add('Name: ${creditCard.cardholderName}');
    }

    if (info.isEmpty) return;

    // Draw background for text
    final textSpan = TextSpan(
      text: info.join('\n'),
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(offset: const Offset(1, 1), blurRadius: 2, color: Colors.black.withOpacity(0.8))],
      ),
    );

    textPainter.text = textSpan;
    textPainter.layout();

    // Position text above the credit card
    final textRect = Rect.fromLTWH(rect.left, rect.top - textPainter.height - 8, textPainter.width, textPainter.height);

    // Draw background rectangle for text
    final backgroundPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(textRect.left - 4, textRect.top - 4, textRect.width + 8, textRect.height + 8),
      backgroundPaint,
    );

    // Draw text
    textPainter.paint(canvas, Offset(textRect.left, textRect.top));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
