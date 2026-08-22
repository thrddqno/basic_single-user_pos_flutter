import 'package:flutter/material.dart';

class ColorHelper {
  /// Convert a Flutter Color to hex string like "#RRGGBB"
  static String toHex(Color color, {bool includeAlpha = false}) {
    String componentToHex(double component) {
      return (component * 255.0)
          .round()
          .clamp(0, 255)
          .toRadixString(16)
          .padLeft(2, '0');
    }

    final alpha = includeAlpha ? componentToHex(color.a) : '';
    final red = componentToHex(color.r);
    final green = componentToHex(color.g);
    final blue = componentToHex(color.b);

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
