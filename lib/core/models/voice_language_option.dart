enum VoiceLanguageOption {
  system,
  spanish,
  english;

  String get storageValue => name;

  String get apiValue => name;

  static VoiceLanguageOption fromApi(String? value) => fromStorage(value);

  static VoiceLanguageOption fromStorage(String? value) {
    switch (value) {
      case 'spanish':
        return VoiceLanguageOption.spanish;
      case 'english':
        return VoiceLanguageOption.english;
      default:
        return VoiceLanguageOption.system;
    }
  }

  /// BCP-47 language code for TTS (`es` / `en`), or null when following the app.
  String? languageCodeOrNull() {
    switch (this) {
      case VoiceLanguageOption.system:
        return null;
      case VoiceLanguageOption.spanish:
        return 'es';
      case VoiceLanguageOption.english:
        return 'en';
    }
  }
}
