import 'package:dio/dio.dart';
import '../core/constants.dart';

class RecordsService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));

  /// Backend GET /api/records uses X-User-ID header and returns
  /// { success: true, records: [...] }
  Future<List<dynamic>> getRecords(String userId) async {
    final response = await _dio.get(
      AppConstants.recordsEndpoint,
      options: Options(headers: {'X-User-ID': userId}),
    );
    final data = response.data;
    if (data is Map && data['records'] != null) {
      return data['records'] as List<dynamic>;
    }
    return [];
  }

  /// Backend POST /api/records expects:
  /// { date: "YYYY-MM-DD", bloodPressure: "120/80", bloodSugar: 100.0, notes: "" }
  Future<Map<String, dynamic>> addRecord({
    required String userId,
    required String? systolic,
    required String? diastolic,
    required String? bloodSugar,
    String? notes,
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Build blood pressure string "systolic/diastolic"
    final bp = (systolic != null && diastolic != null)
        ? '$systolic/$diastolic'
        : (systolic ?? '0') + '/0';

    final sugar = double.tryParse(bloodSugar ?? '') ?? 0.0;

    final response = await _dio.post(
      AppConstants.recordsEndpoint,
      data: {
        'date': dateStr,
        'bloodPressure': bp,
        'bloodSugar': sugar,
        'notes': notes ?? '',
      },
      options: Options(headers: {'X-User-ID': userId}),
    );
    return Map<String, dynamic>.from(response.data);
  }
}
