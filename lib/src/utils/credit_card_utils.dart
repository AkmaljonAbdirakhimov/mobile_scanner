/// Utility functions for credit card detection and validation.
class CreditCardUtils {
  /// Regular expression for credit card numbers (with spaces and dashes).
  static final RegExp _cardNumberPattern = RegExp(r'\b\d{4}[-\s]?\d{4}[-\s]?\d{4}[-\s]?\d{4}\b');

  /// Regular expression for expiry dates (MM/YY or MM/YYYY).
  static final RegExp _expiryPattern = RegExp(r'\b(0[1-9]|1[0-2])[/-]([0-9]{2}|[0-9]{4})\b');

  /// Regular expression for cardholder names (2+ words with proper capitalization).
  static final RegExp _namePattern = RegExp(r'\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)+\b');

  /// Regular expression for CVV codes (3-4 digits).
  static final RegExp _cvvPattern = RegExp(r'\b\d{3,4}\b');

  /// Extract credit card number from text.
  ///
  /// Returns the card number without spaces/dashes, or null if not found/valid.
  static String? extractCardNumber(String text) {
    final RegExpMatch? match = _cardNumberPattern.firstMatch(text);
    if (match == null) return null;

    final String cardNumber = match.group(0)!.replaceAll(RegExp(r'[\s-]'), '');

    // Validate using Luhn algorithm
    if (isValidLuhn(cardNumber)) {
      return cardNumber;
    }

    return null;
  }

  /// Extract expiry date from text.
  ///
  /// Returns the expiry date in MM/YY format, or null if not found.
  static String? extractExpiryDate(String text) {
    final RegExpMatch? match = _expiryPattern.firstMatch(text);
    if (match == null) return null;

    final String expiry = match.group(0)!;

    // Convert MM/YYYY to MM/YY if needed
    if (expiry.contains('/')) {
      final List<String> parts = expiry.split('/');
      if (parts.length == 2) {
        final String month = parts[0];
        final String year = parts[1];

        if (year.length == 4) {
          return '$month/${year.substring(2)}';
        }
        return expiry;
      }
    }

    return expiry;
  }

  /// Extract cardholder name from text.
  ///
  /// Returns the cardholder name, or null if not found.
  static String? extractCardholderName(String text) {
    final RegExpMatch? match = _namePattern.firstMatch(text);
    return match?.group(0);
  }

  /// Extract CVV from text.
  ///
  /// Returns the CVV, or null if not found.
  static String? extractCVV(String text) {
    final RegExpMatch? match = _cvvPattern.firstMatch(text);
    return match?.group(0);
  }

  /// Validate credit card number using Luhn algorithm.
  static bool isValidLuhn(String cardNumber) {
    if (cardNumber.isEmpty) return false;

    // Remove any non-digit characters
    final String digits = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 13 || digits.length > 19) return false;

    int sum = 0;
    bool isEven = false;

    // Process from right to left
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }

  /// Get card type based on card number.
  static String? getCardType(String cardNumber) {
    if (cardNumber.isEmpty) return null;

    // Visa: starts with 4
    if (cardNumber.startsWith('4')) return 'Visa';

    // Mastercard: starts with 51-55 or 2221-2720
    if (RegExp('^5[1-5]').hasMatch(cardNumber) || RegExp('^2[2-7][2-9][0-9]').hasMatch(cardNumber)) {
      return 'Mastercard';
    }

    // American Express: starts with 34 or 37
    if (RegExp('^3[47]').hasMatch(cardNumber)) return 'American Express';

    // Discover: starts with 6011, 622126-622925, 644-649, 65
    if (cardNumber.startsWith('6011') ||
        RegExp('^622(12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[0-1][0-9]|92[0-5])').hasMatch(cardNumber) ||
        RegExp('^64[4-9]').hasMatch(cardNumber) ||
        cardNumber.startsWith('65')) {
      return 'Discover';
    }

    return null;
  }

  /// Mask a credit card number for display.
  static String maskCardNumber(String cardNumber) {
    if (cardNumber.length < 4) return cardNumber;

    final String lastFour = cardNumber.substring(cardNumber.length - 4);
    final String masked = '*' * (cardNumber.length - 4);
    return '$masked$lastFour';
  }

  /// Format a credit card number with spaces every 4 digits for display.
  static String formatCardNumber(String cardNumber) {
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

  /// Validate expiry date.
  static bool isValidExpiryDate(String expiryDate) {
    final RegExpMatch? match = _expiryPattern.firstMatch(expiryDate);
    if (match == null) return false;

    final List<String> parts = expiryDate.split('/');
    if (parts.length != 2) return false;

    final int? month = int.tryParse(parts[0]);
    final int? year = int.tryParse(parts[1]);

    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;

    // Convert 2-digit year to 4-digit year
    final int fullYear = year < 100 ? 2000 + year : year;
    final int currentYear = DateTime.now().year;

    // Check if card is not expired
    if (fullYear < currentYear) return false;
    if (fullYear == currentYear) {
      final int currentMonth = DateTime.now().month;
      if (month < currentMonth) return false;
    }

    return true;
  }
}
