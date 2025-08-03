import 'package:flutter/material.dart';
import 'package:awesome_mobile_scanner/awesome_mobile_scanner.dart';

/// Credit card scanner screen with proper detection configuration
class CreditCardScannerScreen extends StatefulWidget {
  final Function(String cardNumber) onCardDetected;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final Color? overlayColor;
  final Color? borderColor;
  final double? scanAreaWidth;
  final double? scanAreaHeight;
  final double? borderWidth;
  final double? borderRadius;
  final double confidenceThreshold;

  const CreditCardScannerScreen({
    super.key,
    required this.onCardDetected,
    this.appBar,
    this.backgroundColor,
    this.overlayColor,
    this.borderColor,
    this.scanAreaWidth,
    this.scanAreaHeight,
    this.borderWidth,
    this.borderRadius,
    this.confidenceThreshold = 0.7,
  });

  @override
  State<CreditCardScannerScreen> createState() => CreditCardScannerScreenState();
}

class CreditCardScannerScreenState extends State<CreditCardScannerScreen> {
  MobileScannerController? controller;
  CreditCard? _creditCard;
  bool _isCardDetected = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(detectionType: DetectionType.creditCard);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _handleCreditCard(CreditCardCapture capture) {
    if (mounted && capture.creditCards.isNotEmpty) {
      final card = capture.creditCards.first;
      setState(() {
        _creditCard = card;
      });

      // If we have a card number with good confidence, return it
      if (card.cardNumber != null && card.confidence > widget.confidenceThreshold && !_isCardDetected) {
        setState(() {
          _isCardDetected = true;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            final formattedCardNumber = formatCardNumber(card.cardNumber!);
            widget.onCardDetected(formattedCardNumber);
            Navigator.pop(context);
          }
        });
      }
    }
  }

  /// Format a credit card number with spaces every 4 digits for display.
  String formatCardNumber(String cardNumber) {
    // Remove any existing spaces/dashes first
    final String clean = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

    // Add spaces every 4 digits
    final StringBuffer formatted = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted.write(' ');
      }
      formatted.write(clean[i]);
    }
    return formatted.toString();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final scanAreaWidth = widget.scanAreaWidth ?? width * 0.85;
    final scanAreaHeight = widget.scanAreaHeight ?? height * 0.30;
    final backgroundColor = widget.backgroundColor ?? Colors.black;
    final overlayColor = widget.overlayColor ?? Colors.black.withValues(alpha: 0.3);
    final borderColor = widget.borderColor ?? Colors.white;
    final borderWidth = widget.borderWidth ?? 2.0;
    final borderRadius = widget.borderRadius ?? 12.0;

    return Scaffold(
      appBar: widget.appBar,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: widget.appBar != null,
      body: Stack(
        children: [
          MobileScanner(controller: controller, onCreditCardDetect: _handleCreditCard),
          // Black overlay with hole for scanning area
          Positioned.fill(
            child: ClipPath(
              clipper: ScannerClipper(
                scanArea: Rect.fromCenter(
                  center: Offset(width / 2, height / 2),
                  width: scanAreaWidth,
                  height: scanAreaHeight,
                ),
                borderRadius: borderRadius,
              ),
              child: Container(color: overlayColor),
            ),
          ),
          // Scanning box border - positioned above the overlay
          Center(
            child: Container(
              width: scanAreaWidth,
              height: scanAreaHeight,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: borderWidth),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              alignment: Alignment.center,
              child:
                  _creditCard?.cardNumber != null
                      ? Text(
                        formatCardNumber(_creditCard!.cardNumber!),
                        style: TextStyle(fontSize: 24, color: borderColor),
                      )
                      : const Text(''),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom clipper to create a clip path with a hole for the scanning area
class ScannerClipper extends CustomClipper<Path> {
  final Rect scanArea;
  final double borderRadius;

  ScannerClipper({required this.scanArea, this.borderRadius = 12.0});

  @override
  Path getClip(Size size) {
    Path path = Path();

    // Create the outer rectangle (full screen)
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create the inner rectangle (scanning area) with rounded corners
    final scanPath = Path();
    scanPath.addRRect(RRect.fromRectAndRadius(scanArea, Radius.circular(borderRadius)));

    // Subtract the scanning area from the full screen
    path = Path.combine(PathOperation.difference, path, scanPath);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
