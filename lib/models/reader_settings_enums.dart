// File: lib/models/reader_settings_enums.dart

enum ReaderFontFamily {
  systemDefault('System Default'),
  serif('Serif'), // e.g., Noto Serif, Literata
  sansSerif('Sans-Serif'); // e.g., Roboto, Open Sans

  const ReaderFontFamily(this.displayName);
  final String displayName;
}

enum ReaderThemeMode {
  light('Light'),
  dark('Dark'),
  sepia('Sepia');

  const ReaderThemeMode(this.displayName);
  final String displayName;
}