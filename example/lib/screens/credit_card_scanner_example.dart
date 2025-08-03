import 'package:awesome_mobile_scanner/awesome_mobile_scanner.dart';
import 'package:flutter/material.dart';

/// Example screen demonstrating credit card scanning functionality.
///
/// This example shows how to scan credit cards WITHOUT the visual overlay.
/// The credit card detection still works, but no visual shapes are drawn on the screen.
class CreditCardScannerExample extends StatefulWidget {
  /// Constructor for credit card scanner example.
  const CreditCardScannerExample({super.key});

  @override
  State<CreditCardScannerExample> createState() => _CreditCardScannerExampleState();
}

class _CreditCardScannerExampleState extends State<CreditCardScannerExample> {
  MobileScannerController? controller;
  CreditCard? _creditCard;

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
      setState(() {
        _creditCard = capture.creditCards.first;
      });
    }
  }

  Widget _creditCardPreview(CreditCard? card) {
    if (card == null) {
      return const Text('Scan a credit card!', overflow: TextOverflow.fade, style: TextStyle(color: Colors.white));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (card.maskedCardNumber != null)
          Text('Card: ${card.maskedCardNumber}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        if (card.cardNumber != null)
          Text('Card: ${card.cardNumber}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        if (card.expiryDate != null)
          Text('Expiry: ${card.expiryDate}', style: const TextStyle(color: Colors.white, fontSize: 14)),
        if (card.cardholderName != null)
          Text('Name: ${card.cardholderName}', style: const TextStyle(color: Colors.white, fontSize: 14)),
        Text(
          'Confidence: ${(card.confidence * 100).toStringAsFixed(1)}%',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Scanner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: controller, onCreditCardDetect: _handleCreditCard),
          // Credit card overlay - REMOVED
          // if (controller != null)
          //   CreditCardOverlay(
          //     controller: controller!,
          //     boxFit: BoxFit.cover,
          //     color: Colors.blue.withOpacity(0.3),
          //     strokeWidth: 3.0,
          //   ),
          // Info panel at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 120,
              color: const Color.fromRGBO(0, 0, 0, 0.7),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _creditCardPreview(_creditCard),
                    const SizedBox(height: 8),
                    const Text(
                      'Position a credit card in the frame',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
