import 'dart:typed_data';
import 'dart:ui';

/// Represents a detected credit card with extracted information.
class CreditCard {
  /// Creates a new [CreditCard] instance.
  const CreditCard({
    this.cardNumber,
    this.expiryDate,
    this.cardholderName,
    this.cvv,
    this.corners = const <Offset>[],
    this.size = Size.zero,
    this.rawText,
    this.confidence = 0.0,
    this.image,
  });

  /// Creates a new [CreditCard] instance from native platform data.
  factory CreditCard.fromNative(Map<Object?, Object?> data) {
    final List<Object?>? corners = data['corners'] as List<Object?>?;
    final Map<Object?, Object?>? size = data['size'] as Map<Object?, Object?>?;

    final double? cardWidth = size?['width'] as double?;
    final double? cardHeight = size?['height'] as double?;

    return CreditCard(
      cardNumber: data['cardNumber'] as String?,
      expiryDate: data['expiryDate'] as String?,
      cardholderName: data['cardholderName'] as String?,
      cvv: data['cvv'] as String?,
      corners:
          corners == null
              ? const <Offset>[]
              : List.unmodifiable(
                corners.cast<Map<Object?, Object?>>().map((Map<Object?, Object?> e) {
                  final double x = e['x']! as double;
                  final double y = e['y']! as double;
                  return Offset(x, y);
                }),
              ),
      size: cardWidth == null || cardHeight == null ? Size.zero : Size(cardWidth, cardHeight),
      rawText: data['rawText'] as String?,
      confidence: (data['confidence'] as double?) ?? 0.0,
      image: data['image'] as Uint8List?,
    );
  }

  /// The detected card number (may be partially masked for security).
  final String? cardNumber;

  /// The expiry date in MM/YY or MM/YYYY format.
  final String? expiryDate;

  /// The cardholder name as it appears on the card.
  final String? cardholderName;

  /// The CVV code (usually not detected for security reasons).
  final String? cvv;

  /// The corner points of the detected credit card area.
  final List<Offset> corners;

  /// The size of the detected credit card area.
  final Size size;

  /// The raw text that was extracted from the card.
  final String? rawText;

  /// The confidence score of the detection (0.0 to 1.0).
  final double confidence;

  /// The image bytes of the detected card (if requested).
  final Uint8List? image;

  /// Returns a masked version of the card number for display.
  String? get maskedCardNumber {
    if (cardNumber == null || cardNumber!.isEmpty) return null;
    if (cardNumber!.length < 4) return cardNumber;

    final String lastFour = cardNumber!.substring(cardNumber!.length - 4);
    final String masked = '*' * (cardNumber!.length - 4);
    return '$masked$lastFour';
  }

  /// Returns true if this credit card has valid data.
  bool get isValid {
    return cardNumber != null || expiryDate != null || cardholderName != null;
  }

  @override
  String toString() {
    return 'CreditCard(cardNumber: $maskedCardNumber, expiryDate: $expiryDate, cardholderName: $cardholderName, confidence: $confidence)';
  }
}
