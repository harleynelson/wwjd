// File: lib/screens/verse_image_generator_screen.dart
// Path: lib/screens/verse_image_generator_screen.dart
// Updated: initState defaults, gradient dropdown, bottom share button, reference text alignment fix.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../models/verse_image_style.dart';

class VerseImageGeneratorScreen extends StatefulWidget {
  final String initialVerseText;
  final String initialVerseReference;
  final String? initialBookAbbr;
  final String? initialChapter;
  final String? initialVerseNum;

  const VerseImageGeneratorScreen({
    super.key,
    required this.initialVerseText,
    required this.initialVerseReference,
    this.initialBookAbbr,
    this.initialChapter,
    this.initialVerseNum,
  });

  @override
  State<VerseImageGeneratorScreen> createState() => _VerseImageGeneratorScreenState();
}

class _VerseImageGeneratorScreenState extends State<VerseImageGeneratorScreen> {
  late VerseImageStyle _currentStyle;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _isSharing = false;

  late TextEditingController _verseTextController;
  late TextEditingController _verseReferenceController;

  @override
  void initState() {
    super.initState();
    // Initialize with new defaults
    _currentStyle = VerseImageStyle(
      verseText: widget.initialVerseText,
      verseReference: widget.initialVerseReference,
      verseFontFamily: 'Quicksand', // Default
      verseFontSize: 28.0,         // Default
      verseTextAlign: TextAlign.center, // Default
      referenceFontFamily: 'Lato',  // Default
      referenceFontSize: 14.0,      // Default
      referenceTextAlign: TextAlign.center, // Default (will be made effective)
      backgroundType: BackgroundType.gradient,
      predefinedGradient: PredefinedGradient.peachDream, // Default
      aspectRatio: ImageAspectRatio.portrait_4_5, // Default
      textVerticalAlignment: ImageTextVerticalAlignment.center, // Default
      textBlockScale: 0.50, // Default
      // Other defaults like colors will come from VerseImageStyle constructor if not specified here
      verseFontColor: Colors.black87, // Explicit default for chic look
      referenceFontColor: Colors.black54, // Explicit default
    );
    _verseTextController = TextEditingController(text: _currentStyle.verseText);
    _verseReferenceController = TextEditingController(text: _currentStyle.verseReference);
  }

  @override
  void dispose() {
    _verseTextController.dispose();
    _verseReferenceController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
      ),
    );
  }

  Future<void> _generateAndShareImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      RenderRepaintBoundary? boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception("Could not find repaint boundary. Ensure the preview area is visible.");
      }
      
      ui.Image image = await boundary.toImage(pixelRatio: 3.0); 

      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Could not get byte data from image. The image might be too large or an error occurred during conversion.");
      }
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeReference = widget.initialVerseReference.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName = 'verse_image_${safeReference}_$timestamp.png';
      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Shared from WWJD App: ${widget.initialVerseReference}',
        subject: 'Bible Verse: ${widget.initialVerseReference}',
      );
      _showSnackBar('Image shared successfully!');

    } on PlatformException catch (e) {
       _showSnackBar('Sharing failed or was cancelled: ${e.message}', isError: true);
       print("Share PlatformException: ${e.code} - ${e.message} - ${e.details}");
    } on FileSystemException catch (e) {
       _showSnackBar('File system error: ${e.message}', isError: true);
       print("Share FileSystemException: ${e.message} - Path: ${e.path} - OS Error: ${e.osError}");
    } catch (e, s) {
       _showSnackBar('Error generating or sharing image: ${e.toString()}', isError: true);
       print("Share Generic Exception: $e");
       print("Share StackTrace: $s");
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  void _showColorPicker(Function(Color) onColorChanged, Color initialColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Done'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    double screenWidth = MediaQuery.of(context).size.width;
    double previewMaxWidth = screenWidth * 0.9; 
    if (previewMaxWidth > 450) previewMaxWidth = 450; 

    double previewWidth;
    double previewHeight;

    if (_currentStyle.aspectRatio.value >= 1) { 
      previewWidth = previewMaxWidth;
      previewHeight = previewMaxWidth / _currentStyle.aspectRatio.value;
    } else { 
      previewHeight = previewMaxWidth / ImageAspectRatio.square_1_1.value;
      if (previewHeight > 450) previewHeight = 450;
      previewWidth = previewHeight * _currentStyle.aspectRatio.value;
    }

    Alignment textAlignmentValue;
    switch(_currentStyle.textVerticalAlignment) {
      case ImageTextVerticalAlignment.top:
        textAlignmentValue = Alignment.topCenter;
        break;
      case ImageTextVerticalAlignment.bottom:
        textAlignmentValue = Alignment.bottomCenter;
        break;
      case ImageTextVerticalAlignment.center:
      default:
        textAlignmentValue = Alignment.center;
        break;
    }

    return Center(
      child: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: Container(
          width: previewWidth,
          height: previewHeight,
          decoration: _currentStyle.getBackgroundDecoration(),
          child: Stack( 
            children: [
              Align(
                alignment: textAlignmentValue,
                child: Padding(
                  padding: EdgeInsets.all(_currentStyle.padding),
                  child: FractionallySizedBox( 
                    widthFactor: _currentStyle.textBlockScale, 
                    heightFactor: _currentStyle.textBlockScale, 
                    child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      mainAxisAlignment: MainAxisAlignment.center, 
                      crossAxisAlignment: _getCrossAxisAlignment(_currentStyle.verseTextAlign),
                      children: [
                        Flexible( 
                          child: Text(
                            _currentStyle.verseText,
                            style: _currentStyle.getVerseTextStyle(),
                            textAlign: _currentStyle.verseTextAlign,
                          ),
                        ),
                        SizedBox(height: 8 * _currentStyle.textBlockScale), 
                        // Ensure reference text honors its own alignment by having width
                        SizedBox(
                          width: double.infinity, // Make SizedBox take full width of its column slot
                          child: Text(
                            _currentStyle.verseReference,
                            style: _currentStyle.getReferenceTextStyle(),
                            textAlign: _currentStyle.referenceTextAlign, // This will now work
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  CrossAxisAlignment _getCrossAxisAlignment(TextAlign textAlign) {
    switch (textAlign) {
      case TextAlign.left:
      case TextAlign.start:
        return CrossAxisAlignment.start;
      case TextAlign.right:
      case TextAlign.end:
        return CrossAxisAlignment.end;
      case TextAlign.center:
      case TextAlign.justify: 
      default:
        return CrossAxisAlignment.center;
    }
  }

  TextStyle _getFontDropdownStyle(String fontName) {
    try {
      return GoogleFonts.getFont(fontName);
    } catch (e) {
      print("Error loading font '$fontName' for dropdown. Using default.");
      return const TextStyle(); 
    }
  }

  Widget _buildStyleControls() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Added bottom padding for FAB
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Output Format", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<ImageAspectRatio>(
            segments: ImageAspectRatio.values.map((e) =>
              ButtonSegment(value: e, label: Text(e.displayName.split(' ')[0]), icon: Icon(
                e == ImageAspectRatio.square_1_1 ? Icons.crop_square
                : e == ImageAspectRatio.portrait_4_5 ? Icons.crop_portrait
                : Icons.crop_original_outlined 
              ))
            ).toList(),
            selected: {_currentStyle.aspectRatio},
            onSelectionChanged: (newSelection) {
              setState(() => _currentStyle.aspectRatio = newSelection.first);
            },
          ),
          const SizedBox(height: 20),

          Text("Text Position (Vertical)", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
           SegmentedButton<ImageTextVerticalAlignment>(
            segments: ImageTextVerticalAlignment.values.map((e) =>
              ButtonSegment(value: e, label: Text(e.displayName), icon: Icon(
                e == ImageTextVerticalAlignment.top ? Icons.vertical_align_top
                : e == ImageTextVerticalAlignment.bottom ? Icons.vertical_align_bottom
                : Icons.vertical_align_center
              ))
            ).toList(),
            selected: {_currentStyle.textVerticalAlignment},
            onSelectionChanged: (newSelection) {
              setState(() => _currentStyle.textVerticalAlignment = newSelection.first);
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('Text Block Size: ${(_currentStyle.textBlockScale * 100).toInt()}%', style: theme.textTheme.labelLarge),
            subtitle: Slider(
              value: _currentStyle.textBlockScale,
              min: 0.4, max: 1.0, divisions: 12, 
              label: "${(_currentStyle.textBlockScale * 100).toInt()}%",
              onChanged: (val) => setState(() => _currentStyle.textBlockScale = val),
            ),
          ),

          const Divider(height: 30),
          Text("Edit Text (Optional)", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _verseTextController,
            decoration: const InputDecoration(labelText: 'Verse Text', border: OutlineInputBorder()),
            maxLines: 3,
            onChanged: (text) => setState(() => _currentStyle.verseText = text),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _verseReferenceController,
            decoration: const InputDecoration(labelText: 'Reference', border: OutlineInputBorder()),
            onChanged: (text) => setState(() => _currentStyle.verseReference = text),
          ),
          const SizedBox(height: 20),

          Text("Background Style", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<BackgroundType>(
            segments: const [
              ButtonSegment(value: BackgroundType.solid, label: Text('Solid'), icon: Icon(Icons.color_lens_outlined)),
              ButtonSegment(value: BackgroundType.gradient, label: Text('Gradient'), icon: Icon(Icons.gradient_outlined)),
              ButtonSegment(value: BackgroundType.image, label: Text('Image'), icon: Icon(Icons.image_outlined)),
            ],
            selected: {_currentStyle.backgroundType},
            onSelectionChanged: (newSelection) {
              setState(() {
                _currentStyle.backgroundType = newSelection.first;
                if (_currentStyle.backgroundType == BackgroundType.gradient && _currentStyle.predefinedGradient == PredefinedGradient.none) {
                  _currentStyle.predefinedGradient = PredefinedGradient.sunset;
                } else if (_currentStyle.backgroundType == BackgroundType.image && _currentStyle.backgroundImageAsset == null && kSampleBackgroundImages.isNotEmpty) {
                   _currentStyle.backgroundImageAsset = kSampleBackgroundImages.first;
                }
              });
            },
          ),
          const SizedBox(height: 12),

          if (_currentStyle.backgroundType == BackgroundType.solid)
            ListTile(
              leading: const Icon(Icons.square_rounded),
              title: const Text('Background Color'),
              trailing: CircleAvatar(backgroundColor: _currentStyle.backgroundColor, radius: 15),
              onTap: () => _showColorPicker(
                  (color) => setState(() => _currentStyle.backgroundColor = color),
                  _currentStyle.backgroundColor),
            ),

          if (_currentStyle.backgroundType == BackgroundType.gradient)
            DropdownButtonFormField<PredefinedGradient>(
              decoration: const InputDecoration(labelText: 'Select Gradient', border: OutlineInputBorder()),
              value: _currentStyle.predefinedGradient,
              items: PredefinedGradient.values
                  .map((gradient) => DropdownMenuItem(
                        value: gradient,
                        child: Row( // Display gradient swatch next to name
                          children: [
                            Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                gradient: VerseImageStyle.getGradient(gradient),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade400, width: 0.5)
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(getGradientDisplayName(gradient)),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (PredefinedGradient? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentStyle.predefinedGradient = newValue;
                    if (newValue == PredefinedGradient.none) {
                        _currentStyle.backgroundType = BackgroundType.solid;
                        _currentStyle.backgroundColor = Colors.white;
                    }
                  });
                }
              },
            ),
          
          if (_currentStyle.backgroundType == BackgroundType.image)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Text("Select Image:", style: theme.textTheme.labelLarge),
                ),
                SizedBox(
                  height: 80, 
                  child: kSampleBackgroundImages.isEmpty
                  ? const Center(child: Text("No background images available. Add to assets.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: kSampleBackgroundImages.length,
                    itemBuilder: (context, index) {
                      final imagePath = kSampleBackgroundImages[index];
                      bool isSelected = _currentStyle.backgroundImageAsset == imagePath;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentStyle.backgroundImageAsset = imagePath;
                          });
                        },
                        child: Container(
                          width: 70, height: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 1.0,
                            ),
                            image: DecorationImage(
                              image: AssetImage(imagePath),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                print("Error loading asset image for preview: $imagePath");
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

          const Divider(height: 30),
          Text("Verse Text Style", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Verse Font', border: OutlineInputBorder()),
            value: _currentStyle.verseFontFamily,
            items: kChicFonts
                .map((font) => DropdownMenuItem(
                      value: font,
                      child: Text(font, style: _getFontDropdownStyle(font)),
                    ))
                .toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _currentStyle.verseFontFamily = newValue);
              }
            },
          ),
          ListTile(
            dense: true, contentPadding: EdgeInsets.zero,
            title: Text('Verse Font Size: ${_currentStyle.verseFontSize.toInt()}', style: theme.textTheme.labelLarge),
            subtitle: Slider(
              value: _currentStyle.verseFontSize, min: 12, max: 72, divisions: 60,
              label: _currentStyle.verseFontSize.round().toString(),
              onChanged: (double value) => setState(() => _currentStyle.verseFontSize = value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.format_color_text_rounded),
            title: const Text('Verse Font Color'),
            trailing: CircleAvatar(backgroundColor: _currentStyle.verseFontColor, radius: 15),
            onTap: () => _showColorPicker(
                (color) => setState(() => _currentStyle.verseFontColor = color),
                _currentStyle.verseFontColor),
          ),
          Text("Verse Alignment", style: theme.textTheme.labelLarge),
          SegmentedButton<TextAlign>(
            segments: const [
              ButtonSegment(value: TextAlign.left, label: Text('Left'), icon: Icon(Icons.format_align_left)),
              ButtonSegment(value: TextAlign.center, label: Text('Center'), icon: Icon(Icons.format_align_center)),
              ButtonSegment(value: TextAlign.right, label: Text('Right'), icon: Icon(Icons.format_align_right)),
            ],
            selected: {_currentStyle.verseTextAlign},
            onSelectionChanged: (newSelection) => setState(() => _currentStyle.verseTextAlign = newSelection.first),
          ),
          SwitchListTile(
            title: const Text('Bold Verse Text'),
            value: _currentStyle.verseFontWeight == FontWeight.bold,
            onChanged: (bool value) => setState(() => _currentStyle.verseFontWeight = value ? FontWeight.bold : FontWeight.normal),
            dense: true,
          ),

          const Divider(height: 30),
          Text("Reference Text Style", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
           DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Reference Font', border: OutlineInputBorder()),
            value: _currentStyle.referenceFontFamily,
            items: kChicFonts
                .map((font) => DropdownMenuItem(
                      value: font,
                      child: Text(font, style: _getFontDropdownStyle(font)), 
                    ))
                .toList(),
            onChanged: (String? newValue) => setState(() => _currentStyle.referenceFontFamily = newValue ?? _currentStyle.referenceFontFamily),
          ),
          ListTile(
            dense: true, contentPadding: EdgeInsets.zero,
            title: Text('Reference Font Size: ${_currentStyle.referenceFontSize.toInt()}', style: theme.textTheme.labelLarge),
            subtitle: Slider(
              value: _currentStyle.referenceFontSize, min: 8, max: 36, divisions: 28,
              label: _currentStyle.referenceFontSize.round().toString(),
              onChanged: (double value) => setState(() => _currentStyle.referenceFontSize = value),
            ),
          ),
           ListTile(
            leading: const Icon(Icons.format_color_text_outlined),
            title: const Text('Reference Font Color'),
            trailing: CircleAvatar(backgroundColor: _currentStyle.referenceFontColor, radius: 15),
            onTap: () => _showColorPicker(
                (color) => setState(() => _currentStyle.referenceFontColor = color),
                _currentStyle.referenceFontColor),
          ),
          Text("Reference Alignment", style: theme.textTheme.labelLarge),
          SegmentedButton<TextAlign>(
            segments: const [
              ButtonSegment(value: TextAlign.left, label: Text('Left'), icon: Icon(Icons.format_align_left)),
              ButtonSegment(value: TextAlign.center, label: Text('Center'), icon: Icon(Icons.format_align_center)),
              ButtonSegment(value: TextAlign.right, label: Text('Right'), icon: Icon(Icons.format_align_right)),
            ],
            selected: {_currentStyle.referenceTextAlign},
            onSelectionChanged: (newSelection) => setState(() => _currentStyle.referenceTextAlign = newSelection.first),
          ),
          SwitchListTile(
            title: const Text('Bold Reference Text'),
            value: _currentStyle.referenceFontWeight == FontWeight.bold,
            onChanged: (bool value) => setState(() => _currentStyle.referenceFontWeight = value ? FontWeight.bold : FontWeight.normal),
            dense: true,
          ),
          const SizedBox(height: 20), // Extra space before potential bottom share button
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verse Image Creator'),
        actions: [
          IconButton( // Share button in AppBar remains
            icon: _isSharing 
                ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5,)) 
                : const Icon(Icons.share_outlined),
            tooltip: 'Share Image',
            onPressed: _generateAndShareImage,
          ),
        ],
      ),
      body: Column( // Main layout is a Column
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: _buildPreviewArea(),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded( // Style controls take up the remaining space and are scrollable
            child: _buildStyleControls(),
          ),
          // Bottom Share Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: _isSharing 
                  ? const SizedBox(width:18, height:18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0,)) 
                  : const Icon(Icons.share_rounded),
              label: const Text('Generate & Share Image'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48), // Make button wide
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _generateAndShareImage,
            ),
          ),
        ],
      ),
    );
  }
}

