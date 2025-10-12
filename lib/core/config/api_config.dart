class ApiConfig {
  // Replace with YOUR computer's IP address from Step 1
  static const String baseUrl = 'http://192.168.1.7:5000/api';

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}