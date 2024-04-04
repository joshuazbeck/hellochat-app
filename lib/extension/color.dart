import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

//https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter
//@credit - Yeasin Shiekh
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".  Returns a [Color] object or `Colors.transparent` if `hex` was invalid.
  static Color fromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.transparent;
    }
  }

  static String randomHex() {
    StringBuffer sb = StringBuffer();
    for (var i = 0; i < 6; i++) {
      sb.write(Random().nextInt(16).toRadixString(16));
    }
    return "#$sb";
  }
}
