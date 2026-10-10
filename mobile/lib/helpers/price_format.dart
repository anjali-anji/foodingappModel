class PriceFormat {
  PriceFormat._();

  static String inr(double value) => '₹${value.toStringAsFixed(0)}';
}
