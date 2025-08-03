import 'package:awesome_mobile_scanner/awesome_mobile_scanner.dart';
import 'package:flutter/material.dart';

/// Example screen demonstrating credit card scanning functionality using the new CreditCardScannerScreen.
class CreditCardScannerExample extends StatefulWidget {
  /// Constructor for credit card scanner example.
  const CreditCardScannerExample({super.key});

  @override
  State<CreditCardScannerExample> createState() => _CreditCardScannerExampleState();
}

class _CreditCardScannerExampleState extends State<CreditCardScannerExample> {
  String? _scannedCardNumber;

  void _onCardDetected(String cardNumber) {
    setState(() {
      _scannedCardNumber = cardNumber;
    });

    // Show a dialog with the scanned card number
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Card Detected!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Card Number: $cardNumber'),
                const SizedBox(height: 16),
                const Text('This is an example of how to use the CreditCardScannerScreen.'),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Scanner Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Display previously scanned card
          if (_scannedCardNumber != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Last Scanned Card:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(_scannedCardNumber!, style: const TextStyle(fontSize: 18, fontFamily: 'monospace')),
                ],
              ),
            ),

          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How to use:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                Text('1. Tap the "Scan Credit Card" button below'),
                Text('2. Position a credit card in the scanning area'),
                Text('3. The app will automatically detect and format the card number'),
                Text('4. The scanner will close automatically when a card is detected'),
              ],
            ),
          ),

          const Spacer(),

          // Scan button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => CreditCardScannerScreen(
                            onCardDetected: _onCardDetected,
                            appBar: AppBar(
                              title: const Text('Scan Credit Card'),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            backgroundColor: Colors.black,
                            overlayColor: Colors.black.withValues(alpha: 0.3),
                            borderColor: Colors.white,
                            scanAreaWidth: MediaQuery.of(context).size.width * 0.85,
                            scanAreaHeight: MediaQuery.of(context).size.height * 0.30,
                            borderWidth: 2.0,
                            borderRadius: 12.0,
                            confidenceThreshold: 0.7,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Scan Credit Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
