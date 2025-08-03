package dev.steenbakker.mobile_scanner.utils

import com.google.mlkit.vision.text.Text
import dev.steenbakker.mobile_scanner.objects.CreditCard
import kotlin.math.max
import kotlin.math.min

/**
 * Utility class for extracting credit card information from OCR text.
 */
object CreditCardExtractor {
    
    // Regular expression patterns for credit card data extraction
    private val CARD_NUMBER_PATTERN = Regex("\\b\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}\\b")
    private val EXPIRY_PATTERN = Regex("\\b(0[1-9]|1[0-2])[/-]([0-9]{2}|[0-9]{4})\\b")
    private val NAME_PATTERN = Regex("\\b[A-Z][a-z]+\\s+[A-Z][a-z]+\\b")
    private val CVV_PATTERN = Regex("\\b\\d{3,4}\\b")
    
    /**
     * Extract credit card information from OCR text.
     */
    fun extractCreditCards(text: Text, confidenceThreshold: Double): List<CreditCard> {
        val creditCards = mutableListOf<CreditCard>()
        
        for (block in text.textBlocks) {
            for (line in block.lines) {
                val lineText = line.text
                val lineConfidence: Double = try {
                    line.confidence?.toString()?.toDoubleOrNull() ?: 0.0
                } catch (e: Exception) {
                    0.0
                }
                
                // Skip lines with low confidence
                if (lineConfidence < confidenceThreshold) continue
                
                val cardNumber = extractCardNumber(lineText)
                val expiryDate = extractExpiryDate(lineText)
                val cardholderName = extractCardholderName(lineText)
                val cvv = extractCVV(lineText)
                
                // Create credit card if we found any valid data
                if (cardNumber != null || expiryDate != null || cardholderName != null) {
                    val corners = line.cornerPoints?.map { point ->
                        mapOf("x" to point.x.toDouble(), "y" to point.y.toDouble())
                    } ?: emptyList()
                    
                    val size = if (line.boundingBox != null) {
                        mapOf(
                            "width" to line.boundingBox!!.width().toDouble(),
                            "height" to line.boundingBox!!.height().toDouble()
                        )
                    } else {
                        mapOf("width" to 0.0, "height" to 0.0)
                    }
                    
                    val creditCard = CreditCard(
                        cardNumber = cardNumber,
                        expiryDate = expiryDate,
                        cardholderName = cardholderName,
                        cvv = cvv,
                        corners = corners,
                        size = size,
                        rawText = lineText,
                        confidence = lineConfidence
                    )
                    
                    creditCards.add(creditCard)
                }
            }
        }
        
        return creditCards
    }
    
    /**
     * Extract credit card number from text.
     */
    private fun extractCardNumber(text: String): String? {
        val match = CARD_NUMBER_PATTERN.find(text) ?: return null
        val cardNumber = match.value.replace(Regex("[\\s-]"), "")
        
        // Validate using Luhn algorithm
        return if (isValidLuhn(cardNumber)) cardNumber else null
    }
    
    /**
     * Extract expiry date from text.
     */
    private fun extractExpiryDate(text: String): String? {
        val match = EXPIRY_PATTERN.find(text) ?: return null
        val expiry = match.value
        
        // Convert MM/YYYY to MM/YY if needed
        return if (expiry.contains("/")) {
            val parts = expiry.split("/")
            if (parts.size == 2) {
                val month = parts[0]
                val year = parts[1]
                if (year.length == 4) {
                    "$month/${year.substring(2)}"
                } else {
                    expiry
                }
            } else {
                expiry
            }
        } else {
            expiry
        }
    }
    
    /**
     * Extract cardholder name from text.
     */
    private fun extractCardholderName(text: String): String? {
        val match = NAME_PATTERN.find(text)
        return match?.value
    }
    
    /**
     * Extract CVV from text.
     */
    private fun extractCVV(text: String): String? {
        val match = CVV_PATTERN.find(text)
        return match?.value
    }
    
    /**
     * Validate credit card number using Luhn algorithm.
     */
    private fun isValidLuhn(cardNumber: String): Boolean {
        if (cardNumber.isEmpty()) return false
        
        // Remove any non-digit characters
        val digits = cardNumber.replace(Regex("\\D"), "")
        
        if (digits.length < 13 || digits.length > 19) return false
        
        var sum = 0
        var isEven = false
        
        // Process from right to left
        for (i in digits.length - 1 downTo 0) {
            val digit = digits[i].toString().toInt()
            
            if (isEven) {
                val doubled = digit * 2
                sum += if (doubled > 9) doubled - 9 else doubled
            } else {
                sum += digit
            }
            
            isEven = !isEven
        }
        
        return sum % 10 == 0
    }
    
    /**
     * Get card type based on card number.
     */
    fun getCardType(cardNumber: String): String? {
        if (cardNumber.isEmpty()) return null
        
        return when {
            cardNumber.startsWith("4") -> "Visa"
            Regex("^5[1-5]").matches(cardNumber) || Regex("^2[2-7][2-9][0-9]").matches(cardNumber) -> "Mastercard"
            Regex("^3[47]").matches(cardNumber) -> "American Express"
            cardNumber.startsWith("6011") || 
            Regex("^622(12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[0-1][0-9]|92[0-5])").matches(cardNumber) ||
            Regex("^64[4-9]").matches(cardNumber) || 
            cardNumber.startsWith("65") -> "Discover"
            else -> null
        }
    }
    
    /**
     * Mask a credit card number for display.
     */
    fun maskCardNumber(cardNumber: String): String {
        if (cardNumber.length < 4) return cardNumber
        
        val lastFour = cardNumber.substring(cardNumber.length - 4)
        val masked = "*".repeat(cardNumber.length - 4)
        return "$masked$lastFour"
    }
} 