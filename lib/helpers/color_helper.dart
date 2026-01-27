import 'package:flutter/material.dart';

class ColorHelper {
  /// Convert a Flutter Color to hex string like "#RRGGBB"
  static String toHex(Color color, {bool includeAlpha = false}) {
    final alpha = includeAlpha
        ? color.alpha.toRadixString(16).padLeft(2, '0')
        : '';
    final red = color.red.toRadixString(16).padLeft(2, '0');
    final green = color.green.toRadixString(16).padLeft(2, '0');
    final blue = color.blue.toRadixString(16).padLeft(2, '0');

    return '#$alpha$red$green$blue'.toUpperCase();
  }

  /// Convert a hex string like "#RRGGBB" or "#AARRGGBB" to Color
  static Color fromHex(String hexString) {
    hexString = hexString.replaceAll('#', '');

    if (hexString.length == 6) {
      // add full alpha if missing
      hexString = 'FF$hexString';
    }

    return Color(int.parse(hexString, radix: 16));
  }
}
