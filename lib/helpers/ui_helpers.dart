// lib/helpers/ui_helpers.dart
import 'package:flutter/material.dart';
import 'dart:math';

class UiHelper {
  static LinearGradient generateGradient(String seedText) {
    final random = Random(seedText.hashCode);
    Color startColor = Color.fromARGB(
      255,
      100 + random.nextInt(100), // Keep it somewhat vibrant but not too light
      100 + random.nextInt(100),
      100 + random.nextInt(100),
    );
    Color endColor = Color.fromARGB(
      255,
      startColor.red - 40 + random.nextInt(80),
      startColor.green - 40 + random.nextInt(80),
      startColor.blue - 40 + random.nextInt(80),
    ).withOpacity(0.7);

    // Ensure colors are within valid range
    endColor = Color.fromARGB(
      255,
      endColor.red.clamp(0, 255),
      endColor.green.clamp(0, 255),
      endColor.blue.clamp(0, 255),
    );


    List<Alignment> alignments = [
      Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight,
      Alignment.centerLeft, Alignment.centerRight,
    ];

    return LinearGradient(
      colors: [startColor, endColor],
      begin: alignments[random.nextInt(alignments.length)],
      end: alignments[random.nextInt(alignments.length)],
      //stops: [0.0, 0.7 + random.nextDouble() * 0.3],
    );
  }
}