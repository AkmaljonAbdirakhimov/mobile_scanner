import 'package:flutter/material.dart';
import 'package:awesome_mobile_scanner/awesome_mobile_scanner.dart';

/// This widget represents an overlay that paints the bounding boxes of detected
/// credit cards.
class CreditCardOverlay extends StatefulWidget {
  /// Construct a new [CreditCardOverlay] instance.
  const CreditCardOverlay({
    required this.boxFit,
    required this.controller,
    super.key,
    this.color = const Color(0x4D2196F3),
    this.style = PaintingStyle.stroke,
    this.strokeWidth = 2.0,
  });

  /// The [BoxFit] to use when painting the credit card box.
  final BoxFit boxFit;

  /// The controller that provides the credit cards to display.
  final MobileScannerController controller;

  /// The color to use when painting the credit card box.
  ///
  /// Defaults to [Colors.blue], with an opacity of 30%.
  final Color color;

  /// The style to use when painting the credit card box.
  ///
  /// Defaults to [PaintingStyle.stroke].
  final PaintingStyle style;

  /// The stroke width for the credit card box.
  ///
  /// Defaults to 2.0.
  final double strokeWidth;

  @override
  State<CreditCardOverlay> createState() => _CreditCardOverlayState();
}

class _CreditCardOverlayState extends State<CreditCardOverlay> {
  final _textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);

  @override
  void dispose() {
    _textPainter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized || !value.isRunning || value.error != null) {
          return const SizedBox();
        }

        return StreamBuilder<CreditCardCapture>(
          stream: widget.controller.creditCards,
          builder: (context, snapshot) {
            final CreditCardCapture? creditCardCapture = snapshot.data;

            // No credit card or preview size.
            if (creditCardCapture == null || creditCardCapture.size.isEmpty || creditCardCapture.creditCards.isEmpty) {
              return const SizedBox();
            }

            final overlays = <Widget>[
              for (final CreditCard creditCard in creditCardCapture.creditCards)
                if (!creditCard.size.isEmpty && creditCard.corners.isNotEmpty)
                  CustomPaint(
                    painter: CreditCardPainter(
                      creditCard: creditCard,
                      boxFit: widget.boxFit,
                      cameraPreviewSize: creditCardCapture.size,
                      color: widget.color,
                      style: widget.style,
                      strokeWidth: widget.strokeWidth,
                      textPainter: _textPainter,
                    ),
                  ),
            ];

            return Stack(fit: StackFit.expand, children: overlays);
          },
        );
      },
    );
  }
}
