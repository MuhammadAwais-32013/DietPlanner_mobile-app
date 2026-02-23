import 'package:dio/dio.dart';
import '../core/constants.dart';

class BmiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));

  Future<Map<String, dynamic>> calculateBmi({
    required double height,
    required double weight,
    required String userId,
  }) async {
    final response = await _dio.post(AppConstants.bmiEndpoint, data: {
      'height': height,
      'weight': weight,
      'user_id': userId,
    });
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<dynamic>> getBmiHistory(String userId) async {
    final response = await _dio.get(AppConstants.bmiEndpoint, queryParameters: {
      'user_id': userId,
    });
    return response.data as List<dynamic>;
  }
}
