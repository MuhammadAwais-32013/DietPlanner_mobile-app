import 'package:dio/dio.dart';
import '../core/constants.dart';

class AdminService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));

  /// Correct admin endpoint paths per backend app.py:
  /// GET /api/admin/users         → { success, users: [] }
  /// GET /api/admin/bmi           → { success, bmi_records: [] }
  /// GET /api/admin/diet-plans    → { success, diet_plans: [] }
  /// GET /api/admin/medical-records → { success, records: [] }
  /// GET /api/admin/feedback      → { success, feedback: [] }
  Future<Map<String, dynamic>> getDashboardData() async {
    List<dynamic> users = [];
    List<dynamic> bmi = [];
    List<dynamic> diet = [];
    List<dynamic> records = [];
    List<dynamic> feedback = [];

    try {
      final r = await _dio.get('/admin/users');
      final d = r.data;
      if (d is Map && d['users'] is List) users = d['users'] as List;
    } catch (_) {}

    try {
      final r = await _dio.get('/admin/bmi');
      final d = r.data;
      if (d is Map && d['bmi_records'] is List) bmi = d['bmi_records'] as List;
    } catch (_) {}

    try {
      final r = await _dio.get('/admin/diet-plans');
      final d = r.data;
      if (d is Map && d['diet_plans'] is List) diet = d['diet_plans'] as List;
    } catch (_) {}

    try {
      final r = await _dio.get('/admin/medical-records');
      final d = r.data;
      if (d is Map && d['records'] is List) records = d['records'] as List;
    } catch (_) {}

    try {
      final r = await _dio.get('/admin/feedback');
      final d = r.data;
      if (d is Map && d['feedback'] is List) feedback = d['feedback'] as List;
    } catch (_) {}

    return {
      'users': users,
      'bmi': bmi,
      'diet_plans': diet,
      'records': records,
      'feedback': feedback,
    };
  }
}
