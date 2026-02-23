class AppConstants {
  // ⚠️ Change this to your machine's IP when testing on device
  // For web (chrome): use localhost
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String apiUrl = '$baseUrl/api';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String bmiEndpoint = '/bmi';
  static const String recordsEndpoint = '/records';
  static const String dietPlanEndpoint = '/diet-plan';
  static const String chatSessionEndpoint = '/chat/session';
  static const String adminUsersEndpoint = '/admin/users';
  static const String adminBmiEndpoint = '/admin/bmi';
  static const String adminDietEndpoint = '/admin/diet-plans';
  static const String adminRecordsEndpoint = '/admin/records';
  static const String feedbackEndpoint = '/feedback';

  // SharedPreferences Keys
  static const String kUserId = 'user_id';
  static const String kUserName = 'user_name';
  static const String kUserEmail = 'user_email';
  static const String kToken = 'token';
  static const String kIsLoggedIn = 'is_logged_in';
}
