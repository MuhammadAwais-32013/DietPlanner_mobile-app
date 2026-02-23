import 'package:dio/dio.dart';
import '../core/constants.dart';

class AdminService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.apiUrl));

  Future<Map<String, dynamic>> getDashboardData() async {
    final responses = await Future.wait([
      _dio.get(AppConstants.adminUsersEndpoint).catchError((_) => Response(requestOptions: RequestOptions(), data: [])),
      _dio.get(AppConstants.adminBmiEndpoint).catchError((_) => Response(requestOptions: RequestOptions(), data: [])),
      _dio.get(AppConstants.adminDietEndpoint).catchError((_) => Response(requestOptions: RequestOptions(), data: [])),
      _dio.get(AppConstants.adminRecordsEndpoint).catchError((_) => Response(requestOptions: RequestOptions(), data: [])),
    ]);
    return {
      'users': responses[0].data,
      'bmi': responses[1].data,
      'diet_plans': responses[2].data,
      'records': responses[3].data,
    };
  }
}
