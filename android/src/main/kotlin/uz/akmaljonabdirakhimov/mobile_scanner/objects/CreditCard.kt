package uz.akmaljonabdirakhimovmobile_scanner.objects

/**
 * Represents a detected credit card with extracted information.
 */
data class CreditCard(
    val cardNumber: String?,
    val expiryDate: String?,
    val cardholderName: String?,
    val cvv: String?,
    val corners: List<Map<String, Double>>,
    val size: Map<String, Double>,
    val rawText: String?,
    val confidence: Double
) {
    /**
     * Convert to map for Flutter communication.
     */
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "cardNumber" to cardNumber,
            "expiryDate" to expiryDate,
            "cardholderName" to cardholderName,
            "cvv" to cvv,
            "corners" to corners,
            "size" to size,
            "rawText" to rawText,
            "confidence" to confidence
        )
    }
} 