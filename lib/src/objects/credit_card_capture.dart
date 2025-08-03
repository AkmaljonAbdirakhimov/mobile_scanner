import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_mobile_scanner/src/objects/credit_card.dart';

/// Represents a capture of one or more credit cards from a single frame.
class CreditCardCapture {
  /// Creates a new [CreditCardCapture] instance.
  const CreditCardCapture({required this.creditCards, required this.size, this.image, this.timestamp});

  /// The list of credit cards detected in this capture.
  final List<CreditCard> creditCards;

  /// The size of the camera preview when this capture was made.
  final Size size;

  /// The image bytes of the capture (if requested).
  final Uint8List? image;

  /// The timestamp when this capture was made.
  final DateTime? timestamp;

  /// Creates a new [CreditCardCapture] instance from native platform data.
  factory CreditCardCapture.fromNative(Map<Object?, Object?> data) {
    final List<Object?>? creditCardsData = data['creditCards'] as List<Object?>?;
    final Map<Object?, Object?>? size = data['size'] as Map<Object?, Object?>?;

    final double? width = size?['width'] as double?;
    final double? height = size?['height'] as double?;

    final creditCards =
        creditCardsData == null
            ? <CreditCard>[]
            : creditCardsData.cast<Map<Object?, Object?>>().map(CreditCard.fromNative).toList();

    return CreditCardCapture(
      creditCards: creditCards,
      size: width == null || height == null ? Size.zero : Size(width, height),
      image: data['image'] as Uint8List?,
      timestamp: data['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int) : null,
    );
  }

  /// Returns true if any credit cards were detected.
  bool get hasCreditCards => creditCards.isNotEmpty;

  /// Returns the first detected credit card, or null if none were detected.
  CreditCard? get firstCreditCard => creditCards.isNotEmpty ? creditCards.first : null;

  @override
  String toString() {
    return 'CreditCardCapture(creditCards: ${creditCards.length}, size: $size)';
  }
}
