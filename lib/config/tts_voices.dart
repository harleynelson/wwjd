// lib/config/tts_voices.dart

// A simple class to represent a TTS voice for the dropdown
class AppTtsVoice {
  final String name; // The exact voice name for the API (e.g., "en-US-Wavenet-D")
  final String displayName; // User-friendly name for the dropdown
  final String languageCode; // e.g., "en-US"
  final String? ssmlGender; // "MALE", "FEMALE", "NEUTRAL" (optional, for display/filtering)

  const AppTtsVoice({
    required this.name,
    required this.displayName,
    required this.languageCode,
    this.ssmlGender,
  });

  // For DropdownButton value equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppTtsVoice &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

// Curated list of Google Cloud TTS voices for the app
final List<AppTtsVoice> googleTtsAppVoices = [
  // --- Chirp HD Female F ---
  const AppTtsVoice(name: "en-US-Chirp-HD-F", displayName: "US English - Chirp HD (Female F)", languageCode: "en-US", ssmlGender: "FEMALE"),

  // --- Chirp3-HD Voices (from your list) ---
  const AppTtsVoice(name: "en-US-Chirp3-HD-Aoede", displayName: "US English - Chirp3 HD Aoede (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Puck", displayName: "US English - Chirp3 HD Puck (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Charon", displayName: "US English - Chirp3 HD Charon (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Kore", displayName: "US English - Chirp3 HD Kore (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Fenrir", displayName: "US English - Chirp3 HD Fenrir (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Leda", displayName: "US English - Chirp3 HD Leda (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Orus", displayName: "US English - Chirp3 HD Orus (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Zephyr", displayName: "US English - Chirp3 HD Zephyr (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Achird", displayName: "US English - Chirp3 HD Achird (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Algenib", displayName: "US English - Chirp3 HD Algenib (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Algieba", displayName: "US English - Chirp3 HD Algieba (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Alnilam", displayName: "US English - Chirp3 HD Alnilam (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Autonoe", displayName: "US English - Chirp3 HD Autonoe (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Callirrhoe", displayName: "US English - Chirp3 HD Callirrhoe (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Despina", displayName: "US English - Chirp3 HD Despina (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Enceladus", displayName: "US English - Chirp3 HD Enceladus (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Erinome", displayName: "US English - Chirp3 HD Erinome (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Gacrux", displayName: "US English - Chirp3 HD Gacrux (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Iapetus", displayName: "US English - Chirp3 HD Iapetus (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Laomedeia", displayName: "US English - Chirp3 HD Laomedeia (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Pulcherrima", displayName: "US English - Chirp3 HD Pulcherrima (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Rasalgethi", displayName: "US English - Chirp3 HD Rasalgethi (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Sadachbia", displayName: "US English - Chirp3 HD Sadachbia (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Sadaltager", displayName: "US English - Chirp3 HD Sadaltager (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Schedar", displayName: "US English - Chirp3 HD Schedar (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Sulafat", displayName: "US English - Chirp3 HD Sulafat (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Umbriel", displayName: "US English - Chirp3 HD Umbriel (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Vindemiatrix", displayName: "US English - Chirp3 HD Vindemiatrix (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Zubenelgenubi", displayName: "US English - Chirp3 HD Zubenelgenubi (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Chirp3-HD-Achernar", displayName: "US English - Chirp3 HD Achernar (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  
  // --- Adding some of the previous standard, Wavenet, Neural2 as fallbacks/options ---
  const AppTtsVoice(name: "en-US-Neural2-D", displayName: "US English - Neural2 D (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Neural2-A", displayName: "US English - Neural2 A (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Wavenet-D", displayName: "US English - WaveNet D (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Wavenet-A", displayName: "US English - WaveNet A (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),
  const AppTtsVoice(name: "en-US-Standard-B", displayName: "US English - Standard B (Male)", languageCode: "en-US", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-US-Standard-C", displayName: "US English - Standard C (Female)", languageCode: "en-US", ssmlGender: "FEMALE"),

  // UK Voices for variety if desired
  const AppTtsVoice(name: "en-GB-Neural2-B", displayName: "UK English - Neural2 B (Male)", languageCode: "en-GB", ssmlGender: "MALE"),
  const AppTtsVoice(name: "en-GB-Neural2-A", displayName: "UK English - Neural2 A (Female)", languageCode: "en-GB", ssmlGender: "FEMALE"),
];
