import 'package:dio/dio.dart';
import '../core/constants.dart';

class DietService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));

  Future<List<dynamic>> getDietPlans(String userId) async {
    final response = await _dio.get(AppConstants.dietPlanEndpoint, queryParameters: {
      'user_id': userId,
    });
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> generateDietPlan({
    required String sessionId,
    required int days,
    String? preferences,
  }) async {
    final response = await _dio.post(
      '${AppConstants.apiUrl}/chat/$sessionId/generate-diet-plan',
      data: {
        'days': days,
        if (preferences != null) 'preferences': preferences,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }
}
