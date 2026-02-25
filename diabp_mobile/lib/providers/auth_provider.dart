import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _userName;
  String? _userEmail;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final AuthService _authService = AuthService();

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(AppConstants.kIsLoggedIn) ?? false;
    _userId = prefs.getString(AppConstants.kUserId);
    _userName = prefs.getString(AppConstants.kUserName);
    _userEmail = prefs.getString(AppConstants.kUserEmail);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        _userId = result['id']?.toString();  // backend returns 'id', not 'user_id'
        _userName = result['name'] ?? email.split('@').first;
        _userEmail = email;
        _isLoggedIn = true;
        await prefs.setBool(AppConstants.kIsLoggedIn, true);
        await prefs.setString(AppConstants.kUserId, _userId ?? '');
        await prefs.setString(AppConstants.kUserName, _userName ?? '');
        await prefs.setString(AppConstants.kUserEmail, _userEmail ?? '');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Login failed. Check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Make sure the backend is running.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signup(name, email, password);
      if (result['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Signup failed. Try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Make sure the backend is running.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userId = null;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }
}
