class ApiConstants {
  ApiConstants._();

  /// Physical phone over USB: 127.0.0.1 needs `adb reverse tcp:3000 tcp:3000`.
  /// Emulator: 10.0.2.2. Do not use LAN IPs — they change and firewall-timeout.
  static const List<String> baseUrlCandidates = [
    'http://127.0.0.1:3000',
    'http://10.0.2.2:3000',
  ];

  static String baseUrl = baseUrlCandidates.first;

  static const String register = '/register';
  static const String login = '/login';
  static const String foods = '/foods';
  static const String orders = '/orders';
  static const String paymentCreate = '/payment/create';
  static const String paymentVerify = '/payment/verify';
}
