import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/constants.dart';

class ChatService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));

  Future<String?> createSession({
    Map<String, dynamic>? medicalCondition,
    List<MultipartFile>? files,
  }) async {
    try {
      final formData = FormData.fromMap({
        'medical_condition': jsonEncode(medicalCondition ?? {}),
        if (files != null) 'files': files,
      });
      final response = await _dio.post(AppConstants.chatSessionEndpoint, data: formData);
      return response.data['session_id'] as String?;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String sessionId,
    required String message,
    required List<Map<String, dynamic>> chatHistory,
  }) async {
    final response = await _dio.post(
      '/chat/$sessionId/message',
      data: {
        'message': message,
        'chat_history': chatHistory,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> generateDietPlan({
    required String sessionId,
    required int days,
    String? preferences,
  }) async {
    final response = await _dio.post(
      '/chat/$sessionId/generate-diet-plan',
      data: {
        'days': days,
        if (preferences != null) 'preferences': preferences,
      },
    );
    return Map<String, dynamic>.from(response.data);
  }
}
