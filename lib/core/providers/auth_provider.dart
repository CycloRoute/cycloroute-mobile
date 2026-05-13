import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  bool _agreedToTerms = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  bool get agreedToTerms => _agreedToTerms;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userEmail = prefs.getString('userEmail');
    _agreedToTerms = prefs.getBool('agreedToTerms') ?? false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      // Simulate login (in real app, call backend API)
      if (email.isNotEmpty && password.length >= 6) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
        _isLoggedIn = true;
        _userEmail = email;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      // Simulate registration (in real app, call backend API)
      if (email.isNotEmpty && password.length >= 6) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
        _isLoggedIn = true;
        _userEmail = email;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> agreeToTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreedToTerms', true);
    _agreedToTerms = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userEmail = null;
    _agreedToTerms = false;
    notifyListeners();
  }
}
