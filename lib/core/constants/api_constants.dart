class ApiConstants {
<<<<<<< HEAD
  static const String baseUrl = 'http://192.168.0.28:8080/v1';
=======
  static const String baseUrl = 'http://10.0.2.2:8080/v1';
>>>>>>> 52b362492a0d4bb37457296bc8afd097bc83b256

  // Auth endpoints
  static const String verifyToken = '/auth/verify-token';

  // Product endpoints
  static const String products = '/products';

  // Timeout
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}