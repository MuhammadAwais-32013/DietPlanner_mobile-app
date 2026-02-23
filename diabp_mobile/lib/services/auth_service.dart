import 'package:dio/dio.dart';
import '../core/constants.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(AppConstants.loginEndpoint, data: {
        'email': email,
        'password': password,
      });
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return Map<String, dynamic>.from(e.response!.data ?? {'message': 'Login failed'});
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final response = await _dio.post(AppConstants.signupEndpoint, data: {
        'name': name,
        'email': email,
        'password': password,
      });
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        return Map<String, dynamic>.from(e.response!.data ?? {'message': 'Signup failed'});
      }
      rethrow;
    }
  }
}
