import 'package:dio/dio.dart';
import '../core/constants.dart';

class BmiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));

  /// Backend POST /api/bmi uses X-User-ID header and expects { height, weight }
  /// Returns { success, bmi, category }
  Future<Map<String, dynamic>> calculateBmi({
    required double height,
    required double weight,
    required String userId,
  }) async {
    final response = await _dio.post(
      AppConstants.bmiEndpoint,
      data: {
        'height': height,
        'weight': weight,
      },
      options: Options(headers: {'X-User-ID': userId}),
    );
    return Map<String, dynamic>.from(response.data);
  }
}
