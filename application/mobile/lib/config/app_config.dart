class AppConfig {
  /// Backend origin. Override per device without editing call sites:
  /// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
  ///
  /// iOS Simulator: http://127.0.0.1:8000
  /// Android Emulator: http://10.0.2.2:8000
  /// Physical phone: http://컴퓨터_LAN_IP:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// Show an extra caution when YOLO confidence is below this value.
  /// The value is a recognition score, not a medical accuracy rate.
  static const double lowConfidenceThreshold = 0.7;
}
