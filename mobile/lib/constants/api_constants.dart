class ApiConstants {
  ApiConstants._();

  /// USB phone only. Run: adb reverse tcp:3000 tcp:3000
  /// 10.0.2.2 is emulator-only and hangs 6s on a real phone — do not use.
  static const List<String> baseUrlCandidates = [
    'http://127.0.0.1:3000',
  ];

  static String baseUrl = baseUrlCandidates.first;

  static const String register = '/register';
  static const String login = '/login';
  static const String foods = '/foods';
  static const String orders = '/orders';
  static const String paymentCreate = '/payment/create';
  static const String paymentVerify = '/payment/verify';
}
