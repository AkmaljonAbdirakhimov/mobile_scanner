# Credit Card Scanner Screen

The `CreditCardScannerScreen` is a pre-built, customizable screen for scanning credit cards using the awesome_mobile_scanner package.

## Features

- **Automatic Detection**: Automatically detects credit cards using OCR
- **Customizable UI**: Fully customizable colors, sizes, and styling
- **Confidence Threshold**: Configurable confidence threshold for detection
- **Auto-formatting**: Automatically formats card numbers with spaces
- **Auto-close**: Automatically closes when a card is detected with high confidence

## Usage

### Basic Usage

```dart
import 'package:awesome_mobile_scanner/awesome_mobile_scanner.dart';

// Navigate to the scanner
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => CreditCardScannerScreen(
      onCardDetected: (String cardNumber) {
        // Handle the detected card number
        print('Detected card: $cardNumber');
        Navigator.pop(context);
      },
    ),
  ),
);
```

### Advanced Usage with Customization

```dart
CreditCardScannerScreen(
  onCardDetected: (String cardNumber) {
    // Handle the detected card number
    setState(() {
      _scannedCardNumber = cardNumber;
    });
    Navigator.pop(context);
  },
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
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onCardDetected` | `Function(String)` | **Required** | Callback when a card is detected |
| `appBar` | `PreferredSizeWidget?` | `null` | Custom app bar widget |
| `backgroundColor` | `Color?` | `Colors.black` | Background color of the screen |
| `overlayColor` | `Color?` | `Colors.black.withValues(alpha: 0.3)` | Color of the overlay outside scan area |
| `borderColor` | `Color?` | `Colors.white` | Color of the scanning area border |
| `scanAreaWidth` | `double?` | `width * 0.85` | Width of the scanning area |
| `scanAreaHeight` | `double?` | `height * 0.30` | Height of the scanning area |
| `borderWidth` | `double?` | `2.0` | Width of the scanning area border |
| `borderRadius` | `double?` | `12.0` | Border radius of the scanning area |
| `confidenceThreshold` | `double` | `0.7` | Minimum confidence required for detection |

## How it Works

1. The screen initializes a `MobileScannerController` with `DetectionType.creditCard`
2. When a credit card is detected, it checks the confidence level
3. If confidence is above the threshold, it formats the card number and calls `onCardDetected`
4. The screen automatically closes after a 1-second delay to show the detected card

## Example

See `example/lib/screens/credit_card_scanner_example.dart` for a complete working example. 