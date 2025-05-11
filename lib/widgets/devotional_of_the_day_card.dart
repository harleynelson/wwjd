// lib/widgets/devotional_of_the_day_card.dart
// Path: lib/widgets/devotional_of_the_day_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../helpers/daily_devotions.dart'; // For Devotional model
import 'animated_religious_background_card.dart';
import '../theme/app_colors.dart';
import '../models/reader_settings_enums.dart';
import '../services/text_to_speech_service.dart';
// --- NEW IMPORT ---
import './tts_play_button.dart';
// --- END NEW ---


class DevotionalOfTheDayCard extends StatefulWidget {
  final Devotional devotional;
  final bool isLoading;
  final bool enableCardAnimations;
  final int speckCount;
  final double fontSizeDelta;
  final ReaderFontFamily readerFontFamily;

  const DevotionalOfTheDayCard({
    super.key,
    required this.devotional,
    this.isLoading = false,
    this.enableCardAnimations = true,
    this.speckCount = 15,
    this.fontSizeDelta = 0.0,
    this.readerFontFamily = ReaderFontFamily.systemDefault,
  });

  @override
  State<DevotionalOfTheDayCard> createState() => _DevotionalOfTheDayCardState();
}

class _DevotionalOfTheDayCardState extends State<DevotionalOfTheDayCard> {
  bool _isExpanded = false;
  // TextToSpeechService instance is now managed by TtsPlayButton or used directly by speakScriptFunction
  // final TextToSpeechService _ttsService = TextToSpeechService(); 

  static const double _baseTitleFontSize = 19.0;
  static const double _baseCoreMessageFontSize = 16.0;
  static const double _baseScriptureFontSize = 15.0; // Was likely present
  static const double _baseReflectionFontSize = 14.0; // <<< THIS WAS MISSING
  static const double _baseDeclarationLabelFontSize = 14.0; // Ensure this is also present
  static const double _baseDeclarationTextFontSize = 15.0; // Ensure this is also present
  static const double _baseLabelFontSize = 12.0; // For "Daily Reflection" label

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // This function will be passed to TtsPlayButton's speakScriptFunction
  Future<void> _speakDevotionalScriptCallback(TextToSpeechService service, Devotional scriptData) async {
    await service.speakDevotionalScript(scriptData);
  }

  // Provider for the script data
  Future<Devotional?> _getDevotionalScriptDataProvider() async {
    if (widget.devotional.title == "No Devotional Available" ||
        widget.devotional.title == "Content Coming Soon" ||
        widget.isLoading) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No devotional content to read.")),
        );
      }
      return null;
    }
    return widget.devotional;
  }


  TextStyle _getTextStyle(
      ReaderFontFamily family, double baseSize, FontWeight fontWeight, Color color,
      {FontStyle? fontStyle, double? letterSpacing, double? height}) {
    double currentSize = baseSize + widget.fontSizeDelta;
    TextStyle defaultStyle = TextStyle(
      fontSize: currentSize,
      fontWeight: fontWeight,
      color: color,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
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
    final ThemeData appTheme = Theme.of(context);
    final ColorScheme colorScheme = appTheme.colorScheme;

    final Color primaryDarkText = Colors.black.withOpacity(0.87);
    final Color secondaryDarkText = Colors.black.withOpacity(0.70);
    final Color accentScriptureRefColor = colorScheme.primary.computeLuminance() > 0.5
        ? Color.lerp(colorScheme.primary, Colors.black, 0.4)!
        : colorScheme.primary;
    final Color audioButtonColorForThisCard = accentScriptureRefColor; // Used by TtsPlayButton

    // ... (isLoading and No Devotional Available placeholder cards remain the same) ...
    if (widget.isLoading) {
      return SizedBox(
        height: 200,
        child: AnimatedReligiousBackgroundCard(
          gradientColors: AppColors.loadingPlaceholderGradient,
          enableGodRays: false,
          enableLightSpecks: false,
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
        ),
      );
    }

    if (widget.devotional.title == "No Devotional Available" || widget.devotional.title == "Content Coming Soon") {
        final placeholderTitleStyle = _getTextStyle(widget.readerFontFamily, _baseTitleFontSize * 0.8, FontWeight.bold, colorScheme.onSurfaceVariant);
        final placeholderCoreMessageStyle = _getTextStyle(widget.readerFontFamily, _baseCoreMessageFontSize * 0.9, FontWeight.normal, colorScheme.onSurfaceVariant);
        final placeholderReflectionStyle = _getTextStyle(widget.readerFontFamily, _baseReflectionFontSize * 0.9, FontWeight.normal, colorScheme.onSurfaceVariant.withOpacity(0.8));

      return AnimatedReligiousBackgroundCard(
        gradientColors: AppColors.mutedPlaceholderGradient,
        enableGodRays: false,
        enableLightSpecks: false,
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Daily Reflection", style: placeholderTitleStyle),
              const SizedBox(height: 12.0),
              Text(widget.devotional.coreMessage, style: placeholderCoreMessageStyle, textAlign: TextAlign.center),
              const SizedBox(height: 8.0),
              Text(widget.devotional.reflection, style: placeholderReflectionStyle, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    
    final TextStyle dailyReflectionLabelStyle = _getTextStyle(ReaderFontFamily.systemDefault, 12.0, FontWeight.w500, secondaryDarkText.withOpacity(0.8));
    final TextStyle titleStyle = _getTextStyle(widget.readerFontFamily, _baseTitleFontSize, FontWeight.bold, primaryDarkText);
    final TextStyle coreMessageStyle = _getTextStyle(widget.readerFontFamily, _baseCoreMessageFontSize, FontWeight.w600, secondaryDarkText, fontStyle: FontStyle.italic);
    final TextStyle baseScriptureStyle = _getTextStyle(widget.readerFontFamily, 15.0, FontWeight.normal, primaryDarkText, height: 1.5);
    final TextStyle scriptureFocusItalicStyle = baseScriptureStyle.copyWith(fontStyle: FontStyle.italic);
    final TextStyle scriptureRefStyle = _getTextStyle(widget.readerFontFamily, 15.0, FontWeight.bold, accentScriptureRefColor, height: 1.5);
    final TextStyle reflectionTextStyle = _getTextStyle(widget.readerFontFamily, 14.0, FontWeight.normal, secondaryDarkText, height: 1.6);
    final TextStyle declarationLabelStyle = _getTextStyle(widget.readerFontFamily, 14.0, FontWeight.bold, primaryDarkText);
    final TextStyle declarationTextStyle = _getTextStyle(widget.readerFontFamily, 15.0, FontWeight.w500, colorScheme.tertiary.computeLuminance() > 0.5 ? Color.lerp(colorScheme.tertiary, Colors.black, 0.4)! : colorScheme.tertiary, fontStyle: FontStyle.italic);
    final TextStyle readMoreStyle = _getTextStyle(ReaderFontFamily.systemDefault, 14.0, FontWeight.bold, accentScriptureRefColor);


    Widget devotionalContent = Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Daily Reflection", style: dailyReflectionLabelStyle),
                  // --- REPLACED WITH TtsPlayButton ---
                  TtsPlayButton<Devotional>(
                    scriptProvider: _getDevotionalScriptDataProvider,
                    speakScriptFunction: _speakDevotionalScriptCallback,
                    hasPremiumAccess: true, // TTS for daily devotional is not premium
                    isPremiumFeature: false,
                    iconColor: audioButtonColorForThisCard,
                    // iconSize will use default from TtsPlayButton
                  ),
                  // --- END REPLACEMENT ---
                ],
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(widget.devotional.title, style: titleStyle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(widget.devotional.coreMessage, style: coreMessageStyle, maxLines: _isExpanded ? null : 3, overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis),
              const SizedBox(height: 12.0),
              if (widget.devotional.scriptureFocus.isNotEmpty) ...[
                RichText(
                  text: TextSpan(
                    style: baseScriptureStyle,
                    children: [
                      TextSpan(text: '"${widget.devotional.scriptureFocus}" ', style: scriptureFocusItalicStyle),
                      TextSpan(text: widget.devotional.scriptureReference, style: scriptureRefStyle),
                    ],
                  ),
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12.0),
              ],
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(color: primaryDarkText.withOpacity(0.2)),
                    const SizedBox(height: 12.0),
                    SelectableText(widget.devotional.reflection, style: reflectionTextStyle, textAlign: TextAlign.justify),
                    const SizedBox(height: 16.0),
                    Divider(color: primaryDarkText.withOpacity(0.2)),
                    const SizedBox(height: 12.0),
                    Text("Today's Declaration:", style: declarationLabelStyle),
                    const SizedBox(height: 8.0),
                    SelectableText(widget.devotional.prayerDeclaration, style: declarationTextStyle),
                  ],
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              InkWell(
                onTap: () { setState(() { _isExpanded = !_isExpanded; }); },
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(_isExpanded ? "Show Less" : "Read More", style: readMoreStyle),
                      const SizedBox(width: 4.0),
                      Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: accentScriptureRefColor, size: 20.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

    return AnimatedReligiousBackgroundCard(
      gradientColors: AppColors.devotionalCardTwoColorGradient,
      beginGradientAlignment: Alignment.topRight,
      endGradientAlignment: Alignment.bottomLeft,
      enableGodRays: widget.enableCardAnimations,
      enableLightSpecks: widget.enableCardAnimations,
      numberOfSpecks: widget.speckCount,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: devotionalContent,
    );
  }
}