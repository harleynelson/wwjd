// lib/services/text_to_speech_service.dart
import 'dart:io' show Platform;
import 'dart:math'; // For random greetings
import 'package:flutter/foundation.dart'; // For ValueNotifier
import 'package:flutter_tts/flutter_tts.dart';
import '../helpers/daily_devotions.dart'; // Import Devotional model

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;

  late FlutterTts _flutterTts;

  final ValueNotifier<bool> isSpeakingNotifier = ValueNotifier(false);
  final ValueNotifier<List<Map<dynamic, dynamic>>> availableVoicesNotifier =
      ValueNotifier([]);
  final ValueNotifier<Map<dynamic, dynamic>?> selectedVoiceNotifier =
      ValueNotifier(null);

  double _speechRate = 0.55;
  double _pitch = 0.9;
  String _targetLanguage = "en-US";
  bool _sequenceCancelled = false; // To handle stop during sequence

  TextToSpeechService._internal() {
    _flutterTts = FlutterTts();
    _initializeTtsAndLoadDefaults();
  }

  Future<void> _setAwaitOptions() async {
    // Ensure speak completion is awaited for sequenced speaking
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _initializeTtsAndLoadDefaults() async {
    _flutterTts.setStartHandler(() {
      // isSpeakingNotifier.value = true; // Will be set by speak methods
    });

    _flutterTts.setCompletionHandler(() {
      // Only set to false if not immediately starting another part of a sequence
      // The speakDevotionalScript will manage the overall speaking state.
      // If _sequenceCancelled is false, it means a single utterance completed.
      // If it's a part of a sequence, the sequence handler should manage the final state.
    });

    _flutterTts.setErrorHandler((msg) {
      isSpeakingNotifier.value = false;
      _sequenceCancelled = true; // Stop sequence on error
      print("TTS Service Error: $msg");
    });

    // iOS specific settings
    if (Platform.isIOS) {
      try {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            ],
            IosTextToSpeechAudioMode.voicePrompt);
      } catch (e) {
         print("TTS Service: Error setting iOS audio category: $e");
      }
    }
    
    await _setAwaitOptions(); // Crucial for sequenced speaking
    await _checkAndSetInitialLanguage();
    await _loadAndSetDefaultVoice();
  }

  Future<void> _checkAndSetInitialLanguage() async {
    // ... (previous implementation is fine)
    print("TTS Service: Checking language availability for $_targetLanguage");
    try {
      bool? isTargetLangAvailable = await _flutterTts.isLanguageAvailable(_targetLanguage);
      print("TTS Service: Language '$_targetLanguage' available: $isTargetLangAvailable");

      if (isTargetLangAvailable == true) {
        await _flutterTts.setLanguage(_targetLanguage);
        print("TTS Service: Initial language successfully set to $_targetLanguage");
      } else {
        print("TTS Service WARN: Target language '$_targetLanguage' is NOT available.");
        bool? isGenericEnAvailable = await _flutterTts.isLanguageAvailable("en");
        print("TTS Service: Language 'en' available: $isGenericEnAvailable");
        if (isGenericEnAvailable == true) {
          _targetLanguage = "en";
          await _flutterTts.setLanguage(_targetLanguage);
          print("TTS Service: Initial language successfully set to '$_targetLanguage'");
        } else {
          print("TTS Service ERROR: Neither '$_targetLanguage' nor 'en' are available. TTS may use system default language.");
        }
      }
    } catch (e) {
      print("TTS Service: Error during initial language check/set: $e");
    }
  }

  Future<void> _loadAndSetDefaultVoice() async {
    // ... (previous implementation is fine, ensure it calls setVoice)
    try {
      var voices = await _flutterTts.getVoices;
      if (voices != null && voices is List && voices.isNotEmpty) {
        availableVoicesNotifier.value = List<Map<dynamic, dynamic>>.from(
            voices.map((v) => v as Map<dynamic, dynamic>));
        
        print("TTS Service: Available Voices (${availableVoicesNotifier.value.length}):");
        for (var v in availableVoicesNotifier.value) {
          print("  - Name: ${v['name']}, Locale: ${v['locale']}, Gender: ${v['gender']}, Identifier: ${v['identifier']}, Engine: ${v['engine']}");
        }

        Map<dynamic, dynamic>? voiceToSelect;
        int foundIndex = -1;

        // Priority 1: Male "en-US" voice
        foundIndex = availableVoicesNotifier.value.indexWhere(
            (v) => (v["locale"]?.toString().toLowerCase() == "en-us" || v["locale"]?.toString().toLowerCase() == "en_us") &&
                   (v["name"]?.toString().toLowerCase().contains("male") == true ||
                    v["gender"]?.toString().toLowerCase() == "male" ||
                    ["david", "john", "paul", "james", "mark", "tom", "guy", "man"]
                        .any((namePart) => v["name"]?.toString().toLowerCase().contains(namePart) == true)));
        
        if (foundIndex != -1) {
          voiceToSelect = availableVoicesNotifier.value[foundIndex];
          print("TTS Service: Found preferred 'en-US male' voice: ${voiceToSelect['name']}");
        } else {
          foundIndex = availableVoicesNotifier.value.indexWhere(
              (v) => v["locale"]?.toString().toLowerCase() == "en-us" || v["locale"]?.toString().toLowerCase() == "en_us");
          if (foundIndex != -1) {
            voiceToSelect = availableVoicesNotifier.value[foundIndex];
            print("TTS Service: No specific 'male' en-US voice, using first available 'en-US': ${voiceToSelect['name']}");
          } else {
            foundIndex = availableVoicesNotifier.value.indexWhere(
                (v) => v["locale"]?.toString().toLowerCase().startsWith("en") == true);
             if (foundIndex != -1) {
                voiceToSelect = availableVoicesNotifier.value[foundIndex];
                print("TTS Service: No 'en-US' voices, using first available generic 'en': ${voiceToSelect['name']}");
             } else if (availableVoicesNotifier.value.isNotEmpty) {
                voiceToSelect = availableVoicesNotifier.value.first;
                print("TTS Service WARNING: No English voices found. Using first overall available voice: ${voiceToSelect['name']} (Locale: ${voiceToSelect['locale']}). This might not be English.");
             }
          }
        }
        await setVoice(voiceToSelect);
      } else {
         print("TTS Service: No voices returned from getVoices or list is empty.");
         selectedVoiceNotifier.value = null;
         await _flutterTts.setLanguage(_targetLanguage);
      }
    } catch (e) {
      print("TTS Service: Error getting/processing voices: $e");
      selectedVoiceNotifier.value = null;
      await _flutterTts.setLanguage(_targetLanguage);
    }
  }

  List<Map<dynamic, dynamic>> get availableVoices => availableVoicesNotifier.value;
  Map<dynamic, dynamic>? get currentVoice => selectedVoiceNotifier.value;
  double get currentSpeechRate => _speechRate;
  double get currentPitch => _pitch;
  String get currentLanguage => _targetLanguage;

  Future<void> setLanguage(String language, {bool forceSetting = false}) async {
    // ... (previous implementation is fine)
    if (forceSetting || _targetLanguage != language) {
        _targetLanguage = language; 
    }
    try {
      await _flutterTts.setLanguage(language);
      print("TTS Service: Attempted to set language on engine to $language");
    } catch (e) {
      print("TTS Service: Error setting language on engine to $language: $e");
    }
  }

  Future<void> setVoice(Map<dynamic, dynamic>? voice) async {
    // ... (previous implementation is fine)
    if (voice == null) {
      selectedVoiceNotifier.value = null;
      print("TTS Service: Voice cleared. Will use default for language '$_targetLanguage'.");
      await _flutterTts.setLanguage(_targetLanguage);
      return;
    }

    final String voiceName = voice['name']?.toString() ?? "";
    final String voiceLocale = voice['locale']?.toString() ?? "";
    final String? voiceIdentifier = voice['identifier']?.toString();

    print("TTS Service: Attempting to set voice: Name='$voiceName', Locale='$voiceLocale', Identifier='$voiceIdentifier'");

    try {
      bool voiceSetAttempted = false;
      if (Platform.isIOS && voiceIdentifier != null && voiceIdentifier.isNotEmpty) {
        await _flutterTts.setVoice({"identifier": voiceIdentifier});
        print("TTS Service: Voice set via identifier (iOS): $voiceIdentifier");
        voiceSetAttempted = true;
      } else if (voiceName.isNotEmpty && voiceLocale.isNotEmpty) {
        await _flutterTts.setVoice({"name": voiceName, "locale": voiceLocale});
        print("TTS Service: Voice set via name/locale: Name='$voiceName', Locale='$voiceLocale'");
        voiceSetAttempted = true;
      } else {
        print("TTS Service WARN: Critical properties (name/locale or identifier) missing for voice: $voice. Cannot set specific voice.");
      }

      if (voiceSetAttempted) {
        selectedVoiceNotifier.value = voice;
        if (voiceLocale.isNotEmpty) {
          await setLanguage(voiceLocale, forceSetting: true); 
        }
      } else {
        selectedVoiceNotifier.value = null;
        await _flutterTts.setLanguage(_targetLanguage);
        print("TTS Service: Failed to set specific voice, ensuring language is '$_targetLanguage'.");
      }
    } catch (e) {
      print("TTS Service: Error setting voice $voice: $e");
      selectedVoiceNotifier.value = null;
      await _flutterTts.setLanguage(_targetLanguage);
    }
  }

  Future<void> setSpeechRate(double rate) async {
    // ... (previous implementation is fine)
    final clampedRate = rate.clamp(0.1, 1.0); 
    try {
      await _flutterTts.setSpeechRate(clampedRate);
      _speechRate = clampedRate;
      print("TTS Service: Speech rate set to $_speechRate");
    } catch (e) {
      print("TTS Service: Error setting speech rate to $clampedRate: $e");
    }
  }

  Future<void> setPitch(double pitch) async {
    // ... (previous implementation is fine)
     final clampedPitch = pitch.clamp(0.5, 2.0);
    try {
      await _flutterTts.setPitch(clampedPitch);
      _pitch = clampedPitch;
      print("TTS Service: Pitch set to $_pitch");
    } catch (e) {
      print("TTS Service: Error setting pitch to $clampedPitch: $e");
    }
  }

  // Internal speak method for single utterances
  Future<void> _speakInternal(String text) async {
    if (text.isEmpty || _sequenceCancelled) return;

    // Ensure current settings are applied
    String langToUse = _targetLanguage;
    if (selectedVoiceNotifier.value != null &&
        selectedVoiceNotifier.value!['locale'] != null &&
        selectedVoiceNotifier.value!['locale'].toString().isNotEmpty) {
      langToUse = selectedVoiceNotifier.value!['locale'].toString();
    }
    await _flutterTts.setLanguage(langToUse);

    if (selectedVoiceNotifier.value != null) {
      final voiceMap = selectedVoiceNotifier.value!;
      final String voiceName = voiceMap['name']?.toString() ?? "";
      final String voiceLocale = voiceMap['locale']?.toString() ?? "";
      final String? voiceIdentifier = voiceMap['identifier']?.toString();
      if (Platform.isIOS && voiceIdentifier != null && voiceIdentifier.isNotEmpty) {
        await _flutterTts.setVoice({"identifier": voiceIdentifier});
      } else if (voiceName.isNotEmpty && voiceLocale.isNotEmpty) {
        await _flutterTts.setVoice({"name": voiceName, "locale": voiceLocale});
      }
    }
    
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);

    await _flutterTts.speak(text);
  }


  // --- NEW METHOD for structured devotional reading ---
  Future<void> speakDevotionalScript(Devotional devotional) async {
    if (isSpeakingNotifier.value) {
      await stop(); // Stop if already speaking something else
    }
    isSpeakingNotifier.value = true;
    _sequenceCancelled = false;

    // List of greetings for variation
    const greetings = [
      // Original set
      "Peace and blessings to you.",
      "Let's take a moment to reflect.",
      "Welcome, let's consider today's word.",
      "A moment of inspiration for your day.",
      "Hello there friend. I'm so glad you're here with us today.",
      "It's a beautiful day to discover something wonderful together, isn't it?",
      "I'm so glad you're joining us for today's reflection. Expect good things!",
      "Welcome neighbor. Let's open our hearts to a little encouragement.",
      "Well hello there! It's a great day to be inspired and uplifted.",
      "Friends, it's always a joy to share these moments of reflection with you.",
      "Come on in and let's spend a little time with today's encouraging word.",
      "I believe today has something special in store for you. Let's find out together.",
      "Hello my wonderful friend. Are you ready for a little good news for your spirit?",
      "It's a good day for a good word. So glad you've tuned in.",
      "Welcome! I've been looking forward to sharing this time of reflection with you.",
      "You know, every day is a gift, and I'm so pleased we can unwrap a little wisdom together now.",
      "Hey there, good to see you! Let's see what encouraging thoughts we can explore today.",
      "I'm just so happy you're here. Let's prepare our hearts for a moment of peace and insight.",
      "Let's settle in for a quiet moment together, a chance to hear something that might just lift your day.",
      "Hello, dear friend. I hope you're ready for a little inspiration to brighten your day.",
      "Welcome to this moment of reflection. May it bring you a little joy and peace.",
      "Good day to you! I trust you're ready for an uplifting thought.",
      "A warm welcome to you. Let's share a little light from today's reflection.",
      "So pleased you could join me. There's always something good to discover.",
      "Hello, friend. It's a fine day to fill our minds with hope and truth.",
      "Greetings! Let's open up to the blessings this moment has for us.",
      "I'm believing for something good to touch your heart as we reflect today.",
      "Welcome, welcome! Let's get ready for a word of encouragement.",
      "It's truly a pleasure to have you with us. Let's dive into some inspiration.",
      "May this time of reflection bring a little extra sunshine to your day.",
      "So good of you to be here. Let's see what wonders await in today's message.",
      "Hello, and a very warm welcome. I hope you feel right at home here.",
      "Every day is a fresh start, and I'm glad we can start this part of it together.",
      "Thinking of you, and hoping this reflection brings you peace and joy.",
      "Let's pause for a moment, just you and I, and find some comfort in these words.",
      "It's a wonderful opportunity to grow a little together, don't you think?",
      "I'm just thrilled you're here. Let's expect something good to happen in our hearts.",
      "Welcome to this quiet space of reflection. May you find what your spirit needs.",
      "So glad our paths have crossed for this daily word. Let's begin.",
      "May our hearts be open and our spirits be lifted as we reflect.",
      "What a blessing to gather for these few moments. Let's receive today's message."
    ];
    final greeting = greetings[Random().nextInt(greetings.length)];

    // Prepare scripture reference (remove last 3 letters if they are typical version codes)
    String rawRef = devotional.scriptureReference;
    String formattedRef = rawRef;
    if (rawRef.length > 3) { // Basic check: needs to be longer than a typical 3-letter version code
        // List of common Bible version abbreviations (add more if needed)
        bool isKnownVersion = ["NIV", "ESV", "KJV", "NKJ", "NAS", "MSG", "NLT", "AMP", "NRS", "CSB"] 
            .any((v) => rawRef.toUpperCase().endsWith(v));
        
        if (isKnownVersion) {
            // Try to find the last space to separate the reference from the version
            int lastSpaceIndex = rawRef.lastIndexOf(' ');
            // Ensure the part after the last space looks like a version code (2-3 uppercase letters)
            if (lastSpaceIndex != -1 && 
                rawRef.substring(lastSpaceIndex + 1).toUpperCase().contains(RegExp(r'^[A-Z]{2,3}$'))) {
                 formattedRef = rawRef.substring(0, lastSpaceIndex).trim();
            } else if (RegExp(r'[A-Z]{3}$').hasMatch(rawRef.substring(rawRef.length - 3))) {
                // Fallback for simple 3-letter all-caps versions if no space or different pattern
                 formattedRef = rawRef.substring(0, rawRef.length - 3).trim();
            }
            // If it's just a 2-letter version and ends with it.
            else if (rawRef.length > 2 && RegExp(r'[A-Z]{2}$').hasMatch(rawRef.substring(rawRef.length - 2))) {
                 formattedRef = rawRef.substring(0, rawRef.length - 2).trim();
            }
        }
    }


    try {
      // Sequence of speaking parts
      await _speakInternal(greeting);
      if (_sequenceCancelled) return;

      await _speakInternal("Let's explore today's daily devotional,: ${devotional.title}.");
      if (_sequenceCancelled) return;
      
      await _speakInternal(devotional.coreMessage);
      if (_sequenceCancelled) return;

      await _speakInternal("$formattedRef tells us: ${devotional.scriptureFocus}.");
      if (_sequenceCancelled) return;
      
      // Adding a slight deliberate pause if needed, beyond awaitSpeakCompletion
      // For flutter_tts, `awaitSpeakCompletion(true)` IS the pause.
      // If you need longer pauses, you might speak a very short silence string (engine dependent)
      // or use multiple `awaitSpeakCompletion(true)` with empty speaks, though this is hacky.
      // For now, awaitSpeakCompletion handles the pause between segments.

      await _speakInternal("... ${devotional.reflection}");
      if (_sequenceCancelled) return;

      await _speakInternal("And together, let's declare today...");
      if (_sequenceCancelled) return;
      
      await _speakInternal(devotional.prayerDeclaration);
      // awaitSpeakCompletion is true, so this will wait for the last part to finish

    } catch (e) {
      print("TTS Service (speakDevotionalScript): Error during sequenced speaking: $e");
      _sequenceCancelled = true; // Ensure sequence stops
    } finally {
      // Ensure isSpeakingNotifier is set to false once the whole sequence is done or cancelled
      if (mounted) { // Assuming this service might be used in a context where mounted check is relevant (though less so for a pure service)
         isSpeakingNotifier.value = false;
      } else {
         isSpeakingNotifier.value = false;
      }
    }
  }
  // Helper for mounted check, mainly for ValueNotifier updates if used in a StatefulWidget context directly.
  // For a singleton service, this isn't strictly necessary for its internal logic but doesn't hurt.
  bool get mounted => true; // Simplified for a service context.


  // Original speak method for generic text (can still be used)
  Future<void> speak(String text) async {
    if (text.isEmpty) {
      print("TTS Service: Speak called with empty text.");
      return;
    }
    if (isSpeakingNotifier.value) {
      await stop(); 
    }
    isSpeakingNotifier.value = true; // Set speaking true when this method starts
    _sequenceCancelled = false; // Reset for generic speak

    try {
      await _speakInternal(text); // Use the internal method that sets params
      // awaitSpeakCompletion is true, so it will wait.
    } catch (e) {
      print("TTS Service (speak): Error during speak execution: $e");
      _sequenceCancelled = true;
    } finally {
      // The completion handler of _flutterTts will set isSpeakingNotifier to false.
      // If we want to ensure it's false after this single speak call:
      // (This depends on whether awaitSpeakCompletion truly waits for the handler)
      // For now, rely on the setCompletionHandler for single speaks.
    }
  }


  Future<void> stop() async {
    _sequenceCancelled = true; // Signal any ongoing sequence to stop
    try {
      var result = await _flutterTts.stop();
      if (result == 1) { // 1 usually means success
        isSpeakingNotifier.value = false;
         print("TTS Service: Speech stopped.");
      }
    } catch (e) {
      print("TTS Service: Error stopping speech: $e");
      isSpeakingNotifier.value = false; // Ensure state is correct
    }
  }

  Future<void> pause() async { 
    if (!isSpeakingNotifier.value) return;
    _sequenceCancelled = true; // Pausing should also break a sequence
    try {
      print("TTS Service: Attempting to pause speech.");
      var result = await _flutterTts.pause();
       if (result == 1) {
        isSpeakingNotifier.value = false; 
        print("TTS Service: Speech paused (or stop for Android workaround).");
      }
    } catch (e) {
      print("TTS Service: Error pausing speech: $e");
    }
  }
}