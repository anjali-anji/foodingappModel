class ApiConstants {
  ApiConstants._();

  /// USB phone: 127.0.0.1 (adb reverse). Emulator: 10.0.2.2. Wi-Fi: PC IP.
  static const List<String> baseUrlCandidates = [
    'http://127.0.0.1:3000',
    'http://10.0.2.2:3000',
    'http://10.190.1.213:3000',
  ];

  static String baseUrl = baseUrlCandidates.first;

  static const String register = '/register';
  static const String login = '/login';
  static const String foods = '/foods';
  static const String orders = '/orders';
  static const String paymentCreate = '/payment/create';
  static const String paymentVerify = '/payment/verify';
}
