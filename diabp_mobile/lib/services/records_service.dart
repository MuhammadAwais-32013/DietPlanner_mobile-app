import 'package:dio/dio.dart';
import '../core/constants.dart';

class RecordsService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));

  Future<List<dynamic>> getRecords(String userId) async {
    final response = await _dio.get(AppConstants.recordsEndpoint, queryParameters: {
      'user_id': userId,
    });
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> addRecord({
    required String userId,
    required String? systolic,
    required String? diastolic,
    required String? bloodSugar,
    String? notes,
  }) async {
    final response = await _dio.post(AppConstants.recordsEndpoint, data: {
      'user_id': userId,
      if (systolic != null) 'systolic': int.tryParse(systolic),
      if (diastolic != null) 'diastolic': int.tryParse(diastolic),
      if (bloodSugar != null) 'blood_sugar': double.tryParse(bloodSugar),
      if (notes != null) 'notes': notes,
    });
    return Map<String, dynamic>.from(response.data);
  }
}
