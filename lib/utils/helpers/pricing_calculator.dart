class UPricingCalculator {

  // ==========================================
  // 1. SHIPPING / DELIVERY FEE (Fixed ₹15)
  // ==========================================
  static String calculateShippingCost(double subTotal, String location) {
    // Tune bola 15 kar de, toh ye fixed ₹15 ho gaya
    double shippingCost = 15.0;
    return shippingCost.toStringAsFixed(2);
  }

  // ==========================================
  // 2. TAX FEE (Subtotal ka 5%)
  // ==========================================
  static String calculateTax(double productPrice, String location) {
    // 5% tax nikalne ke liye 0.05 se multiply kiya hai
    double taxRate = 0.05;
    double taxAmount = productPrice * taxRate;
    return taxAmount.toStringAsFixed(2);
  }

  // ==========================================
  // 3. TOTAL PRICE CALCULATION
  // ==========================================
  static double calculateTotalPrice(double productPrice, String location) {
    double taxAmount = double.tryParse(calculateTax(productPrice, location)) ?? 0.0;
    double shippingCost = double.tryParse(calculateShippingCost(productPrice, location)) ?? 0.0;

    // Grand Total = Subtotal + Tax (5%) + Shipping (15)
    double totalPrice = productPrice + taxAmount + shippingCost;
    return totalPrice;
  }
}