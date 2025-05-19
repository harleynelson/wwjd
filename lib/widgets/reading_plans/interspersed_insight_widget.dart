// File: lib/widgets/reading_plans/interspersed_insight_widget.dart
// Path: lib/widgets/reading_plans/interspersed_insight_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wwjd_app/models/models.dart'; 
import 'package:wwjd_app/models/reader_settings_enums.dart'; 

class InterspersedInsightWidget extends StatelessWidget {
  final InterspersedInsight insight;
  final Color textColor;
  final Color subtleBackgroundColor;
  final double baseFontSize; 
  final double fontSizeDelta;
  final ReaderFontFamily fontFamily;

  const InterspersedInsightWidget({
    super.key,
    required this.insight,
    required this.textColor,
    required this.subtleBackgroundColor,
    required this.baseFontSize,
    required this.fontSizeDelta,
    required this.fontFamily,
  });

  TextStyle _getTextStyle(
    ReaderFontFamily family,
    double baseSize,
    FontWeight fontWeight,
    Color color, {
    double height = 1.5,
    FontStyle? fontStyle,
    double currentFontSizeDelta = 0.0, 
  }) {
    double currentSize = baseSize + currentFontSizeDelta;
    TextStyle defaultStyle = TextStyle(
      fontSize: currentSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontStyle: fontStyle,
    );
    switch (family) {
      case ReaderFontFamily.serif:
        return GoogleFonts.notoSerif(textStyle: defaultStyle);
      case ReaderFontFamily.sansSerif:
        return GoogleFonts.roboto(textStyle: defaultStyle);
      case ReaderFontFamily.systemDefault:
      default:
        return defaultStyle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle insightTextStyle = _getTextStyle(
      fontFamily,
      baseFontSize - 2, 
      FontWeight.normal,
      textColor,
      height: 1.5,
      fontStyle: FontStyle.italic,
      currentFontSizeDelta: fontSizeDelta,
    );
    final TextStyle attributionStyle = _getTextStyle(
      fontFamily,
      baseFontSize - 3, 
      FontWeight.w500,
      textColor.withOpacity(0.85),
      height: 1.4,
      fontStyle: FontStyle.italic,
      currentFontSizeDelta: fontSizeDelta,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: subtleBackgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.text,
            style: insightTextStyle,
            textAlign: TextAlign.left,
          ),
          if (insight.attribution != null && insight.attribution!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "- ${insight.attribution}",
                style: attributionStyle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}