// lib/services/text_to_speech_service.dart
// Path: lib/services/text_to_speech_service.dart
// Approximate line: 7 & 30 (and relevant method body)

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // REMOVE THIS LINE
import 'package:firebase_remote_config/firebase_remote_config.dart'; // ADD THIS LINE

import 'package:wwjd_app/config/constants.dart';
import 'package:wwjd_app/dialogs/text_to_speech_dialiog_frils.dart';
import '../helpers/daily_devotions.dart';
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

  // Getter for the API key from Remote Config
  String get _apiKey {
    final key = FirebaseRemoteConfig.instance.getString('google_cloud_tts_api_key');
    if (key.isEmpty) {
      print("TTS Service WARNING: GOOGLE_CLOUD_API_KEY not found in Remote Config or is empty.");
    }
    return key;
  }

  final List<String> _voicesSupportingPitchRate = [
    'Standard', 'Wavenet', 'Neural2'
  ];

  bool _isInitialized = false;
  String? _cacheDirectoryPath;

  TextToSpeechService._internal() {
    _initializeAudioPlayerListeners();
    // ensureInitialized() should be called explicitly from outside if needed before first use
    // or implicitly by methods that depend on it.
    // The API key check will now happen when _apiKey getter is first accessed.
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
    }
  }

  String _generateCacheKey(String text) {
    final voiceId = _currentVoiceNameApi ?? _currentLanguageCode;
    final rate = _speakingRate.toStringAsFixed(2);
    final pitchVal = _pitch.toStringAsFixed(2);
    final String rawKey = "$voiceId-$rate-$pitchVal-$text";
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
          (v) => v.name == defaultVoice, 
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

  Future<Uint8List?> _synthesizeAudio(String text) async {
    if (text.isEmpty) return null;
    final String currentApiKey = _apiKey; // Access the getter
    if (currentApiKey.isEmpty) {
      print("TTS Service: API Key not found or empty (from Remote Config). Cannot synthesize speech.");
      return null;
    }

    final String apiUrl = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=$currentApiKey';
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

  Future<void> _proactivelyCache(String text) async {
    if (!_isInitialized) await ensureInitialized();
    if (text.isEmpty || _cacheDirectoryPath == null) return;

    File? cachedFile = await _getCachedFile(text);
    if (cachedFile != null) {
      return; 
    }

    print("TTS Service: Proactively caching text: '${text.substring(0, min(text.length, 30))}...'");
    Uint8List? audioBytes = await _synthesizeAudio(text);
    if (audioBytes != null) {
      await _saveToCache(text, audioBytes);
    }
  }

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

    await _currentSpeechCompleter!.future.timeout(const Duration(minutes: 2), 
        onTimeout: () {
            print("TTS Service: Playback segment timed out.");
            if (_audioPlayerState == PlayerState.playing) _audioPlayer.stop();
            if (!(_currentSpeechCompleter?.isCompleted ?? true)) {
              _currentSpeechCompleter?.completeError("Segment playback timeout");
            }
            _sequenceCancelled = true; 
        });
  }

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
        await _saveToCache(text, audioBytes); 
        await _playAudioData(audioBytes: audioBytes);
      } else {
        if (!(_currentSpeechCompleter?.isCompleted ?? true)) _currentSpeechCompleter?.completeError("Failed to synthesize audio for playback.");
         _sequenceCancelled = true; 
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

    const greetings = daily_reflection_greetings;
    String greeting = "Welcome.";
    if (greetings.isNotEmpty) {
        greeting = greetings[Random().nextInt(greetings.length)];
    }

    String rawRef = devotional.scriptureReference;
    String formattedRef = rawRef;
    if (rawRef.length > 3) {
        bool isKnownVersion = ["NIV", "ESV", "KJV", "NKJ", "NAS", "MSG", "NLT", "AMP", "NRS", "CSB"]
            .any((v) => rawRef.toUpperCase().endsWith(v));

        if (isKnownVersion) {
            int lastSpaceIndex = rawRef.lastIndexOf(' ');
            if (lastSpaceIndex != -1 &&
                rawRef.substring(lastSpaceIndex + 1).toUpperCase().contains(RegExp(r'^[A-Z]{2,3}$'))) {
                 formattedRef = rawRef.substring(0, lastSpaceIndex).trim();
            } 
            else if (RegExp(r'[A-Z]{3}$').hasMatch(rawRef.substring(rawRef.length - 3))) {
                 formattedRef = rawRef.substring(0, rawRef.length - 3).trim();
            }
            else if (rawRef.length > 2 && RegExp(r'[A-Z]{2}$').hasMatch(rawRef.substring(rawRef.length - 2))) {
                 formattedRef = rawRef.substring(0, rawRef.length - 2).trim();
            }
        }
    }

    final List<String> script = [
      "$greeting ${devotional.title}.",
      devotional.coreMessage,
      "$formattedRef tells us: ${devotional.scriptureFocus}.", 
      "... ${devotional.reflection}",
      "And together, let's declare... ${devotional.prayerDeclaration}.",
    ];

    try {
      for (int i = 0; i < script.length; i++) {
        if (_sequenceCancelled) break;
        final textToSpeak = script[i];

        if (i + 1 < script.length && !_sequenceCancelled) {
          _proactivelyCache(script[i + 1]).catchError((e) {
            print("TTS Service: Error during proactive caching of part ${i+2}: $e");
          });
        }

        await _playOrSynthesizeAndPlay(textToSpeak);

        if (_sequenceCancelled) break; 
      }
    } catch (e) {
      print("TTS Service: Error in speakDevotionalScript playback loop: $e");
      _sequenceCancelled = true;
    } finally {
      if (!_sequenceCancelled) print("TTS Service: Devotional script completed.");
      if (_audioPlayerState != PlayerState.playing && isSpeakingNotifier.value) {
          isSpeakingNotifier.value = false;
      } else if (_sequenceCancelled && isSpeakingNotifier.value){
          isSpeakingNotifier.value = false; 
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
    isSpeakingNotifier.value = true; 
    await _playOrSynthesizeAndPlay(text);
    if (!_sequenceCancelled && _audioPlayerState != PlayerState.playing && isSpeakingNotifier.value) {
        isSpeakingNotifier.value = false;
    } else if (_sequenceCancelled && isSpeakingNotifier.value) {
        isSpeakingNotifier.value = false;
    }
  }

  Future<void> stop() async {
    print("TTS Service: Stop requested. Current isSpeaking: ${isSpeakingNotifier.value}");
    _sequenceCancelled = true;

    if (isSpeakingNotifier.value) {
      isSpeakingNotifier.value = false;
    }

    if (_audioPlayerState == PlayerState.playing || _audioPlayerState == PlayerState.paused) {
      await _audioPlayer.stop(); 
    }

    if (!(_currentSpeechCompleter?.isCompleted ?? true)) {
      _currentSpeechCompleter?.completeError("Speech stopped by user");
    }

    if (isSpeakingNotifier.value) {
       isSpeakingNotifier.value = false;
    }
    print("TTS Service: Speech stop actions processed. isSpeaking: ${isSpeakingNotifier.value}");
  }

  Future<void> pause() async {
    if (_audioPlayerState == PlayerState.playing) {
      await _audioPlayer.pause(); 
      print("TTS Service: Speech pause requested.");
    }
  }

  Future<void> resume() async {
    if (_audioPlayerState == PlayerState.paused) {
      await _audioPlayer.resume(); 
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