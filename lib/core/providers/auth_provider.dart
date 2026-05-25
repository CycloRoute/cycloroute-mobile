import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _fullName;
  String? _userEmail;
  String? _phoneNumber;
  bool _agreedToTerms = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get fullName => _fullName;
  String? get userEmail => _userEmail;
  String? get phoneNumber => _phoneNumber;
  bool get agreedToTerms => _agreedToTerms;
  String get displayName => _fullName?.trim().isNotEmpty == true
      ? _fullName!.trim()
      : (_userEmail?.split('@').first ?? 'Cyclist');

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _fullName = prefs.getString('fullName');
    _userEmail = prefs.getString('userEmail');
    _phoneNumber = prefs.getString('phoneNumber');
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

  Future<bool> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      // Simulate registration (in real app, call backend API)
      if (fullName.isNotEmpty &&
          email.isNotEmpty &&
          phoneNumber.isNotEmpty &&
          password.length >= 6) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('fullName', fullName);
        await prefs.setString('userEmail', email);
        await prefs.setString('phoneNumber', phoneNumber);
        _isLoggedIn = true;
        _fullName = fullName;
        _userEmail = email;
        _phoneNumber = phoneNumber;
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
    _fullName = null;
    _userEmail = null;
    _phoneNumber = null;
    _agreedToTerms = false;
    notifyListeners();
  }
}
