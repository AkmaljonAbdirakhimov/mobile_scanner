import 'dart:async';
import 'dart:js_interop';
import 'dart:ui';

import 'package:mobile_scanner/src/objects/credit_card.dart';
import 'package:mobile_scanner/src/objects/credit_card_capture.dart';
import 'package:mobile_scanner/src/utils/credit_card_utils.dart';
import 'package:web/web.dart';

/// A web implementation of credit card detection using Tesseract.js
class CreditCardReader {
  /// Constructs a [CreditCardReader] instance.
  CreditCardReader();

  /// Whether Tesseract.js is loaded
  bool _isLoaded = false;

  /// The Tesseract worker instance
  dynamic _worker;

  /// Load Tesseract.js library
  Future<void> loadLibrary() async {
    if (_isLoaded) return;

    try {
      // Load Tesseract.js from CDN
      final script =
          HTMLScriptElement()
            ..src = 'https://unpkg.com/tesseract.js@4.1.1/dist/tesseract.min.js'
            ..type = 'text/javascript';

      document.head?.append(script);

      // Wait for script to load
      final completer = Completer<void>();
      script.onload = ((JSAny _) => completer.complete()).toJS;
      await completer.future;

      // Initialize Tesseract worker
      _worker = await (window as dynamic).tesseract.createWorker();
      await _worker.loadLanguage('eng');
      await _worker.initialize('eng');

      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load Tesseract.js: $e');
    }
  }

  /// Detect credit cards from an image
  Future<CreditCardCapture> detectCreditCards(HTMLCanvasElement canvas, {double confidenceThreshold = 0.7}) async {
    if (!_isLoaded) {
      await loadLibrary();
    }

    try {
      // Perform OCR on the canvas
      final result = await _worker.recognize(canvas);
      final text = result.data.text as String;
      final confidence = result.data.confidence as double;

      // Extract credit card information using Dart utilities
      final cardNumber = CreditCardUtils.extractCardNumber(text);
      final expiryDate = CreditCardUtils.extractExpiryDate(text);
      final cardholderName = CreditCardUtils.extractCardholderName(text);
      final cvv = CreditCardUtils.extractCVV(text);

      // Create credit card if we found any valid data
      if (cardNumber != null || expiryDate != null || cardholderName != null) {
        final creditCard = CreditCard(
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cardholderName: cardholderName,
          cvv: cvv,
          corners: const <Offset>[],
          size: Size(canvas.width.toDouble(), canvas.height.toDouble()),
          rawText: text,
          confidence: confidence / 100.0, // Convert percentage to 0-1 range
        );

        return CreditCardCapture(
          creditCards: [creditCard],
          size: Size(canvas.width.toDouble(), canvas.height.toDouble()),
        );
      }

      return CreditCardCapture(
        creditCards: const <CreditCard>[],
        size: Size(canvas.width.toDouble(), canvas.height.toDouble()),
      );
    } catch (e) {
      throw Exception('Failed to detect credit cards: $e');
    }
  }

  /// Dispose the worker
  Future<void> dispose() async {
    if (_worker != null) {
      await _worker.terminate();
      _worker = null;
      _isLoaded = false;
    }
  }
}
