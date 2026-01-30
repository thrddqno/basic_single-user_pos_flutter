String formatPrice(double? value) {
  if (value == null) return '';
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}
