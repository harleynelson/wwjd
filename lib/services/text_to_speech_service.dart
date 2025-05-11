// lib/services/text_to_speech_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Added for File operations
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart'; // Added for cache directory
import 'package:path/path.dart' as p; // Added for path joining
import 'package:wwjd_app/config/constants.dart';

import '../helpers/daily_devotions.dart';
import '../config/api_keys.dart';
import '../config/tts_voices.dart';
import '../helpers/prefs_helper.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState? _audioPlayerState;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  final ValueNotifier<bool> isSpeakingNotifier = ValueNotifier(false);
  final ValueNotifier<AppTtsVoice?> selectedAppVoiceNotifier =
      ValueNotifier(null);

  double _speakingRate = 0.88;
  double _pitch = -3.5;

  String _currentLanguageCode = "en-US";
  String? _currentVoiceNameApi;

  bool _sequenceCancelled = false;
  Completer<void>? _currentSpeechCompleter;

  final String _apiKey = googleCloudApiKey;

  final List<String> _voicesSupportingPitchRate = [
    'Standard', 'Wavenet', 'Neural2'
  ];

  bool _isInitialized = false;
  String? _cacheDirectoryPath;

  TextToSpeechService._internal() {
    _initializeAudioPlayerListeners();
    if (_apiKey == "YOUR_ACTUAL_GOOGLE_CLOUD_API_KEY" || _apiKey.isEmpty) {
      print("TTS Service WARNING: API Key is still the placeholder or empty. "
            "Please update it in lib/config/api_keys.dart");
    }
    // ensureInitialized() should be called explicitly from outside if needed before first use
    // or implicitly by methods that depend on it.
  }

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    await _initializeCacheDirectory();
    await _loadInitialVoiceSettings();
    _isInitialized = true;
    print("TTS Service: Explicitly initialized with cache directory.");
  }

  Future<void> _initializeCacheDirectory() async {
    if (_cacheDirectoryPath != null) return;
    try {
      final directory = await getApplicationSupportDirectory();
      _cacheDirectoryPath = p.join(directory.path, 'tts_cache');
      final cacheDir = Directory(_cacheDirectoryPath!);
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      print("TTS Service: Cache directory set to $_cacheDirectoryPath");
    } catch (e) {
      print("TTS Service: Error initializing cache directory: $e");
      // Handle error, perhaps by disabling caching or alerting the user
    }
  }

  String _generateCacheKey(String text) {
    // Simple hash a unique key. Consider more robust hashing if needed.
    final voiceId = _currentVoiceNameApi ?? _currentLanguageCode;
    final rate = _speakingRate.toStringAsFixed(2);
    final pitchVal = _pitch.toStringAsFixed(2);
    final String rawKey = "$voiceId-$rate-$pitchVal-$text";
    // Using text.hashCode is simple but can have collisions for very different long texts.
    // For devotional segments, it's likely sufficient.
    // A more robust approach for general text might involve a cryptographic hash of 'rawKey'.
    return "${rawKey.hashCode}.mp3";
  }

  Future<File?> _getCachedFile(String text) async {
    if (_cacheDirectoryPath == null) return null;
    final String fileName = _generateCacheKey(text);
    final String filePath = p.join(_cacheDirectoryPath!, fileName);
    final file = File(filePath);
    if (await file.exists()) {
      print("TTS Service: Cache hit for text (hashCode: ${text.hashCode}) -> $fileName");
      return file;
    }
    print("TTS Service: Cache miss for text (hashCode: ${text.hashCode}) -> $fileName");
    return null;
  }

  Future<void> _saveToCache(String text, Uint8List audioBytes) async {
    if (_cacheDirectoryPath == null || audioBytes.isEmpty) return;
    final String fileName = _generateCacheKey(text);
    final String filePath = p.join(_cacheDirectoryPath!, fileName);
    try {
      final file = File(filePath);
      await file.writeAsBytes(audioBytes, flush: true);
      print("TTS Service: Saved to cache $fileName");
    } catch (e) {
      print("TTS Service: Error saving to cache $fileName: $e");
    }
  }

  void _initializeAudioPlayerListeners() {
    _playerStateChangeSubscription?.cancel();
    _playerCompleteSubscription?.cancel();

    _playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      _audioPlayerState = s;
      bool currentlyPlaying = (s == PlayerState.playing);
      if (isSpeakingNotifier.value != currentlyPlaying) {
        isSpeakingNotifier.value = currentlyPlaying;
      }
    });

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      print("TTS Service: AudioPlayer completed an utterance.");
      if (!(_currentSpeechCompleter?.isCompleted ?? true)) {
        _currentSpeechCompleter?.complete();
      }
    });
  }

  Future<void> _loadInitialVoiceSettings() async {
    await PrefsHelper.init();
    String? preferredVoiceName = PrefsHelper.getSelectedVoiceName();
    AppTtsVoice? voiceToSet;

    if (preferredVoiceName != null && preferredVoiceName.isNotEmpty) {
      try {
        voiceToSet = googleTtsAppVoices.firstWhere((v) => v.name == preferredVoiceName);
        print("TTS Service: Loaded preferred voice from Prefs: ${voiceToSet.displayName}");
      } catch (e) {
        print("TTS Service: Preferred voice '$preferredVoiceName' not found. Using default.");
      }
    }

    if (voiceToSet == null) {
      if (googleTtsAppVoices.isNotEmpty) {
        voiceToSet = googleTtsAppVoices.firstWhere(
          (v) => v.name == defaultVoice, // Default preferred voice in constants.dart
          orElse: () => googleTtsAppVoices.firstWhere(
            (v) => v.languageCode == "en-US" && _voicesSupportingPitchRate.any((type) => v.name.toLowerCase().contains(type.toLowerCase())),
            orElse: () => googleTtsAppVoices.first,
          ),
        );
        print("TTS Service: No preferred voice in Prefs or not found. Using default: ${voiceToSet.displayName}");
      } else {
         print("TTS Service WARNING: googleTtsAppVoices list is empty!");
      }
    }
    await setAppVoice(voiceToSet, savePreference: false);
  }

  List<AppTtsVoice> getCuratedAppVoices() {
    return googleTtsAppVoices;
  }

  AppTtsVoice? get currentSelectedAppVoice => selectedAppVoiceNotifier.value;
  double get currentSpeakingRate => _speakingRate;
  double get currentPitch => _pitch;
  String get currentLanguageCode => _currentLanguageCode;

  Future<void> setAppVoice(AppTtsVoice? appVoice, {bool savePreference = true}) async {
    if (appVoice == null) {
       if (googleTtsAppVoices.isNotEmpty) {
        final fallbackVoice = googleTtsAppVoices.firstWhere(
            (v) => v.name == defaultVoice,
            orElse: () => googleTtsAppVoices.first);
        selectedAppVoiceNotifier.value = fallbackVoice;
        _currentVoiceNameApi = fallbackVoice.name;
        _currentLanguageCode = fallbackVoice.languageCode;
      } else {
        selectedAppVoiceNotifier.value = null;
        _currentVoiceNameApi = null;
        _currentLanguageCode = "en-US"; 
      }
      if (savePreference) {
        await PrefsHelper.setSelectedVoiceName("");
        await PrefsHelper.setSelectedVoiceLanguageCode("");
      }
      return;
    }

    selectedAppVoiceNotifier.value = appVoice;
    _currentVoiceNameApi = appVoice.name;
    _currentLanguageCode = appVoice.languageCode;

    if (savePreference) {
      await PrefsHelper.setSelectedVoiceName(appVoice.name);
      await PrefsHelper.setSelectedVoiceLanguageCode(appVoice.languageCode);
    }
    print("TTS Service: AppVoice set to Name: ${_currentVoiceNameApi}, Language: $_currentLanguageCode");
  }

  Future<void> setSpeakingRate(double rate) async {
    _speakingRate = rate.clamp(0.25, 4.0);
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(-20.0, 20.0);
  }

  // Internal method to synthesize audio, does not play, returns bytes.
  Future<Uint8List?> _synthesizeAudio(String text) async {
    if (text.isEmpty) return null;
    if (_apiKey == "YOUR_ACTUAL_GOOGLE_CLOUD_API_KEY" || _apiKey.isEmpty) {
      print("TTS Service: API Key not set. Cannot synthesize speech.");
      return null;
    }

    final String apiUrl = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey';
    final Map<String, dynamic> voiceParams = {'languageCode': _currentLanguageCode};
    if (_currentVoiceNameApi != null) {
      voiceParams['name'] = _currentVoiceNameApi;
    }

    final Map<String, dynamic> audioConfig = {'audioEncoding': 'MP3'};
    bool supportsPitchRate = _currentVoiceNameApi != null &&
        _voicesSupportingPitchRate.any((type) =>
            _currentVoiceNameApi!.toLowerCase().contains(type.toLowerCase()));

    if (supportsPitchRate) {
      audioConfig['speakingRate'] = _speakingRate;
      audioConfig['pitch'] = _pitch;
    }
     print("TTS Service: Synthesizing for cache: '${text.substring(0, min(text.length, 30))}...' with voice: ${_currentVoiceNameApi ?? 'default for $_currentLanguageCode'}");


    final Map<String, dynamic> requestBody = {
      'input': {'text': text}, 'voice': voiceParams, 'audioConfig': audioConfig,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final String? audioBase64 = responseBody['audioContent'] as String?;
        if (audioBase64 != null) {
          return base64Decode(audioBase64);
        }
      } else {
        print("TTS Service: Google TTS API Error (Synthesize Audio) ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("TTS Service: Error synthesizing audio: $e");
    }
    return null;
  }

  // Proactively synthesize and cache a piece of text. Does not play.
  Future<void> _proactivelyCache(String text) async {
    if (!_isInitialized) await ensureInitialized();
    if (text.isEmpty || _cacheDirectoryPath == null) return;

    File? cachedFile = await _getCachedFile(text);
    if (cachedFile != null) {
      // print("TTS Service: Proactive cache check: Already cached for '${text.substring(0, min(text.length, 30))}'.");
      return; // Already cached
    }

    print("TTS Service: Proactively caching text: '${text.substring(0, min(text.length, 30))}...'");
    Uint8List? audioBytes = await _synthesizeAudio(text);
    if (audioBytes != null) {
      await _saveToCache(text, audioBytes);
    }
  }
  
  // Plays audio from bytes or file path, managing the completer.
  Future<void> _playAudioData({Uint8List? audioBytes, String? filePath}) async {
    if (_sequenceCancelled) {
        if (!(_currentSpeechCompleter?.isCompleted ?? true)) _currentSpeechCompleter?.complete();
        return;
    }
    _currentSpeechCompleter = Completer<void>();
    if (audioBytes != null) {
        await _audioPlayer.play(BytesSource(audioBytes));
    } else if (filePath != null) {
        await _audioPlayer.play(DeviceFileSource(filePath));
    } else {
        if (!(_currentSpeechCompleter?.isCompleted ?? true)) _currentSpeechCompleter?.completeError("No audio data to play");
        return;
    }
    
    // Timeout for the playback of a single segment
    await _currentSpeechCompleter!.future.timeout(const Duration(minutes: 2), 
        onTimeout: () {
            print("TTS Service: Playback segment timed out.");
            if (_audioPlayerState == PlayerState.playing) _audioPlayer.stop();
            if (!(_currentSpeechCompleter?.isCompleted ?? true)) {
              _currentSpeechCompleter?.completeError("Segment playback timeout");
            }
            _sequenceCancelled = true; // Stop the whole sequence on timeout
        });
  }


  // Main method to play a single text, using cache if available or synthesizing.
  Future<void> _playOrSynthesizeAndPlay(String text) async {
    if (text.isEmpty || _sequenceCancelled) {
      if (_sequenceCancelled) print("TTS Service: Playback skipped due to cancellation for '${text.substring(0, min(text.length, 30))}'.");
      if (!(_currentSpeechCompleter?.isCompleted ?? true)) _currentSpeechCompleter?.complete();
      return;
    }
     if (!_isInitialized) await ensureInitialized();


    File? cachedFile = await _getCachedFile(text);

    if (cachedFile != null && !_sequenceCancelled) {
      print("TTS Service: Playing from cache: ${cachedFile.path}");
      await _playAudioData(filePath: cachedFile.path);
    } else if (!_sequenceCancelled) {
      print("TTS Service: Synthesizing and playing text: '${text.substring(0, min(text.length, 30))}...'");
      Uint8List? audioBytes = await _synthesizeAudio(text);
      if (audioBytes != null && !_sequenceCancelled) {
        await _saveToCache(text, audioBytes); // Save before playing
        await _playAudioData(audioBytes: audioBytes);
      } else {
        if (!(_currentSpeechCompleter?.isCompleted ?? true)) _currentSpeechCompleter?.completeError("Failed to synthesize audio for playback.");
         _sequenceCancelled = true; // If synthesis fails, cancel sequence
      }
    }
  }


  Future<void> speakDevotionalScript(Devotional devotional) async {
    if (!_isInitialized) await ensureInitialized();
    if (isSpeakingNotifier.value && _audioPlayerState == PlayerState.playing) {
      await stop();
    }
    _sequenceCancelled = false;
    isSpeakingNotifier.value = true;

    const greetings = [
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
    String greeting = "Welcome.";
    if (greetings.isNotEmpty) {
        greeting = greetings[Random().nextInt(greetings.length)];
    }

    // --- Scripture Reference Formatting ---
    String rawRef = devotional.scriptureReference;
    String formattedRef = rawRef;
    if (rawRef.length > 3) {
        // List of common Bible version abbreviations (add more if needed)
        bool isKnownVersion = ["NIV", "ESV", "KJV", "NKJ", "NAS", "MSG", "NLT", "AMP", "NRS", "CSB"]
            .any((v) => rawRef.toUpperCase().endsWith(v));

        if (isKnownVersion) {
            int lastSpaceIndex = rawRef.lastIndexOf(' ');
            // Check if the part after the last space is 2-3 uppercase letters (a version code)
            if (lastSpaceIndex != -1 &&
                rawRef.substring(lastSpaceIndex + 1).toUpperCase().contains(RegExp(r'^[A-Z]{2,3}$'))) {
                 formattedRef = rawRef.substring(0, lastSpaceIndex).trim();
            } 
            // Fallback for 3-letter all-caps versions if no space or different pattern (e.g., "GEN1:1ESV")
            else if (RegExp(r'[A-Z]{3}$').hasMatch(rawRef.substring(rawRef.length - 3))) {
                 formattedRef = rawRef.substring(0, rawRef.length - 3).trim();
            }
            // Fallback for 2-letter all-caps versions
            else if (rawRef.length > 2 && RegExp(r'[A-Z]{2}$').hasMatch(rawRef.substring(rawRef.length - 2))) {
                 formattedRef = rawRef.substring(0, rawRef.length - 2).trim();
            }
        }
    }
    // --- End Scripture Reference Formatting ---

    final List<String> script = [
      "$greeting. Let's explore today's daily reflection... ${devotional.title}.",
      devotional.coreMessage,
      "$formattedRef tells us: ${devotional.scriptureFocus}.", // Use formattedRef
      "... ${devotional.reflection}",
      "And together, let's declare... ${devotional.prayerDeclaration}.",
    ];

    try {
      for (int i = 0; i < script.length; i++) {
        if (_sequenceCancelled) break;
        final textToSpeak = script[i];

        // Proactively cache the next part (if it exists) - do not await
        if (i + 1 < script.length && !_sequenceCancelled) {
          _proactivelyCache(script[i + 1]).catchError((e) {
            print("TTS Service: Error during proactive caching of part ${i+2}: $e");
            // Non-fatal, continue with current playback
          });
        }

        // Play the current part (will use cache if available, or synthesize, cache, and play)
        await _playOrSynthesizeAndPlay(textToSpeak);
        
        if (_sequenceCancelled) break; 
      }
    } catch (e) {
      print("TTS Service: Error in speakDevotionalScript playback loop: $e");
      _sequenceCancelled = true;
    } finally {
      if (!_sequenceCancelled) print("TTS Service: Devotional script completed.");
      // isSpeakingNotifier should be managed by player state changes, but ensure it's false if sequence ends/cancels.
      if (_audioPlayerState != PlayerState.playing && isSpeakingNotifier.value) {
          isSpeakingNotifier.value = false;
      } else if (_sequenceCancelled && isSpeakingNotifier.value){
          isSpeakingNotifier.value = false; // Ensure it's off if cancelled
      }
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await ensureInitialized();
    if (text.isEmpty) return;
    if (isSpeakingNotifier.value && _audioPlayerState == PlayerState.playing) {
      await stop();
    }
    _sequenceCancelled = false;
    isSpeakingNotifier.value = true; // Manually set for single speak
    await _playOrSynthesizeAndPlay(text);
     // For single speaks, if not cancelled and player isn't playing, set notifier false.
    if (!_sequenceCancelled && _audioPlayerState != PlayerState.playing && isSpeakingNotifier.value) {
        isSpeakingNotifier.value = false;
    } else if (_sequenceCancelled && isSpeakingNotifier.value) {
        isSpeakingNotifier.value = false;
    }
  }

  Future<void> stop() async {
    print("TTS Service: Stop requested. Current isSpeaking: ${isSpeakingNotifier.value}");
    _sequenceCancelled = true;

    // Immediately update notifier for faster UI feedback, if it's currently true.
    // The AudioPlayer listener will also update it, but this can be quicker visually.
    if (isSpeakingNotifier.value) {
      isSpeakingNotifier.value = false;
    }

    if (_audioPlayerState == PlayerState.playing || _audioPlayerState == PlayerState.paused) {
      await _audioPlayer.stop(); // This should trigger onPlayerStateChanged -> isSpeakingNotifier = false
    }
    
    if (!(_currentSpeechCompleter?.isCompleted ?? true)) {
      _currentSpeechCompleter?.completeError("Speech stopped by user");
    }
    
    // Ensure isSpeakingNotifier is false after attempting to stop.
    // This is a bit redundant if the listener works perfectly, but acts as a safeguard.
    if (isSpeakingNotifier.value) {
       isSpeakingNotifier.value = false;
    }
    print("TTS Service: Speech stop actions processed. isSpeaking: ${isSpeakingNotifier.value}");
  }

  Future<void> pause() async {
    if (_audioPlayerState == PlayerState.playing) {
      await _audioPlayer.pause(); // This should trigger onPlayerStateChanged
      print("TTS Service: Speech pause requested.");
    }
  }

  Future<void> resume() async {
    if (_audioPlayerState == PlayerState.paused) {
      await _audioPlayer.resume(); // This should trigger onPlayerStateChanged
      print("TTS Service: Speech resume requested.");
    }
  }

  void dispose() {
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
    isSpeakingNotifier.dispose();
    selectedAppVoiceNotifier.dispose();
    print("TTS Service: Disposed.");
  }
}