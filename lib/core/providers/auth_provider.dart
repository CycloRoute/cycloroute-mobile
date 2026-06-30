import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyclerisk/core/navigation/session_handler.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/core/services/api_exception.dart';
import 'package:cyclerisk/core/services/secure_storage_service.dart';
import 'package:cyclerisk/core/models/distance_unit.dart';
import 'package:cyclerisk/core/models/voice_language_option.dart';
import 'package:cyclerisk/features/auth/data/models/auth_session.dart';
import 'package:cyclerisk/features/auth/data/models/auth_user.dart';
import 'package:cyclerisk/features/auth/data/models/bike_profile.dart';
import 'package:cyclerisk/features/auth/data/models/route_preference.dart';
import 'package:cyclerisk/features/auth/data/models/user_role.dart';
import 'package:cyclerisk/features/auth/data/services/auth_api_service.dart';
import 'package:cyclerisk/features/users/data/services/users_api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    AppApiClient.onUnauthorized = _handleUnauthorized;
    _authApiService = AuthApiService(apiClient: AppApiClient.create());
    _usersApiService = UsersApiService(apiClient: AppApiClient.create());
    _initFuture = _loadAuthState();
  }

  static String _onboardingKeyFor(String userId) => 'onboarding_$userId';

  late final AuthApiService _authApiService;
  late final UsersApiService _usersApiService;
  final SecureStorageService _secureStorage = SecureStorageService();
  late final Future<void> _initFuture;

  bool _isInitialized = false;
  bool _isLoggedIn = false;
  String? _accessToken;
  String? _userId;
  String? _firstnames;
  String? _lastnames;
  String? _fullName;
  String? _userEmail;
  String? _phoneNumber;
  UserRole _role = UserRole.user;
  RoutePreference _defaultRoutePreference = RoutePreference.recommended;
  BikeProfile _defaultBikeProfile = BikeProfile.urban;
  bool _voiceGuidanceEnabled = true;
  VoiceLanguageOption _voiceLanguage = VoiceLanguageOption.system;
  DistanceUnit _distanceUnit = DistanceUnit.kilometers;
  bool _agreedToTerms = false;
  bool _hasCompletedPreferenceOnboarding = false;
  ApiException? _lastApiError;
  bool _sessionExpired = false;

  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _isLoggedIn;
  String? get accessToken => _accessToken;
  String? get userId => _userId;
  String? get fullName => _fullName;
  String? get userEmail => _userEmail;
  String? get phoneNumber => _phoneNumber;
  UserRole get role => _role;
  RoutePreference get defaultRoutePreference => _defaultRoutePreference;
  BikeProfile get defaultBikeProfile => _defaultBikeProfile;
  bool get voiceGuidanceEnabled => _voiceGuidanceEnabled;
  VoiceLanguageOption get voiceLanguage => _voiceLanguage;
  DistanceUnit get distanceUnit => _distanceUnit;
  bool get agreedToTerms => _agreedToTerms;
  bool get hasCompletedPreferenceOnboarding =>
      _hasCompletedPreferenceOnboarding;
  ApiException? get lastApiError => _lastApiError;
  bool get sessionExpired => _sessionExpired;
  bool get canReviewInfrastructure => _role.canReviewInfrastructure;

  String get displayName => _fullName?.trim().isNotEmpty == true
      ? _fullName!.trim()
      : (_userEmail?.split('@').first ?? 'Cyclist');
  String get firstName => displayName.split(RegExp(r'\s+')).first;

  AuthUser? get currentUser {
    if (_userId == null || _userEmail == null) {
      return null;
    }

    return AuthUser(
      id: _userId!,
      firstnames: _firstnames ?? '',
      lastnames: _lastnames ?? '',
      name: _fullName ?? '',
      emailAddress: _userEmail!,
      phoneNumber: _phoneNumber,
      role: _role,
      defaultRoutePreference: _defaultRoutePreference,
      defaultBikeProfile: _defaultBikeProfile,
      voiceGuidanceEnabled: _voiceGuidanceEnabled,
      voiceLanguage: _voiceLanguage,
      distanceUnit: _distanceUnit,
    );
  }

  Future<void> ensureInitialized() => _initFuture;

  void _handleUnauthorized() {
    if (!_isLoggedIn) {
      return;
    }
    _sessionExpired = true;
    logout().whenComplete(SessionHandler.handleSessionExpired);
  }

  void clearSessionExpiredFlag() {
    _sessionExpired = false;
    notifyListeners();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    var token = await _secureStorage.readAccessToken();

    if (token == null || token.isEmpty) {
      final legacyToken = prefs.getString('accessToken');
      if (legacyToken != null && legacyToken.isNotEmpty) {
        token = legacyToken;
        await _secureStorage.writeAccessToken(legacyToken);
        await prefs.remove('accessToken');
      }
    }

    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _accessToken = token;
    _userId = prefs.getString('userId');
    _firstnames = prefs.getString('firstnames');
    _lastnames = prefs.getString('lastnames');
    _fullName = prefs.getString('fullName');
    _userEmail = prefs.getString('userEmail');
    _phoneNumber = prefs.getString('phoneNumber');
    _role = UserRole.fromApi(prefs.getString('role'));
    _defaultRoutePreference = RoutePreference.fromApi(
      prefs.getString('defaultRoutePreference'),
    );
    _agreedToTerms = prefs.getBool('agreedToTerms') ?? false;
    _hasCompletedPreferenceOnboarding = _userId == null
        ? false
        : prefs.getBool(_onboardingKeyFor(_userId!)) ?? false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final session = await _authApiService.login(
        emailAddress: email,
        password: password,
      );

      await _persistSession(session);
      return true;
    } on ApiException catch (e) {
      _lastApiError = e;
      notifyListeners();
      return false;
    } catch (e) {
      _lastApiError = ApiException.connectFailed();
      return false;
    }
  }

  Future<bool> register({
    required String firstnames,
    required String lastnames,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final session = await _authApiService.register(
        firstnames: firstnames,
        lastnames: lastnames,
        emailAddress: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );

      await _persistSession(session, resetOnboarding: true);
      return true;
    } on ApiException catch (e) {
      _lastApiError = e;
      notifyListeners();
      return false;
    } catch (e) {
      _lastApiError = ApiException.connectFailed();
      return false;
    }
  }

  Future<String?> forgotPassword(String emailAddress) async {
    try {
      final message = await _authApiService.forgotPassword(
        emailAddress: emailAddress,
      );
      _lastApiError = null;
      notifyListeners();
      return message;
    } on ApiException catch (e) {
      _lastApiError = e.statusCode == 502
          ? ApiException.serviceUnavailable()
          : e;
      notifyListeners();
      return null;
    } catch (_) {
      _lastApiError = ApiException.connectFailed();
      notifyListeners();
      return null;
    }
  }

  Future<bool> resetPassword({
    required String emailAddress,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _authApiService.resetPassword(
        emailAddress: emailAddress,
        code: code,
        newPassword: newPassword,
      );
      _lastApiError = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _lastApiError = e;
      notifyListeners();
      return false;
    } catch (_) {
      _lastApiError = ApiException.connectFailed();
      notifyListeners();
      return false;
    }
  }

  Future<AuthUser?> refreshProfile() async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final user = await _usersApiService.getMe(accessToken: token);
      await _applyUser(user, keepToken: true);
      return user;
    } on ApiException catch (e) {
      _lastApiError = e;
      notifyListeners();
      return null;
    } catch (_) {
      _lastApiError = ApiException.connectFailed();
      notifyListeners();
      return null;
    }
  }

  Future<AuthUser?> updateUserPreferences({
    RoutePreference? defaultRoutePreference,
    BikeProfile? defaultBikeProfile,
    bool? voiceGuidanceEnabled,
    VoiceLanguageOption? voiceLanguage,
    DistanceUnit? distanceUnit,
  }) async {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final user = await _usersApiService.updateMe(
        accessToken: token,
        defaultRoutePreference: defaultRoutePreference,
        defaultBikeProfile: defaultBikeProfile,
        voiceGuidanceEnabled: voiceGuidanceEnabled,
        voiceLanguage: voiceLanguage,
        distanceUnit: distanceUnit,
      );
      await _applyUser(user, keepToken: true);
      return user;
    } on ApiException catch (e) {
      _lastApiError = e;
      notifyListeners();
      return null;
    } catch (_) {
      _lastApiError = ApiException.connectFailed();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateRoutePreference(RoutePreference preference) async {
    final user = await updateUserPreferences(
      defaultRoutePreference: preference,
    );
    return user != null;
  }

  Future<bool> completePreferenceOnboarding(
    RoutePreference preference,
  ) async {
    final success = await updateRoutePreference(preference);
    if (!success) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = _userId;
    if (userId != null) {
      await prefs.setBool(_onboardingKeyFor(userId), true);
    }
    _hasCompletedPreferenceOnboarding = true;
    notifyListeners();
    return true;
  }

  Future<void> _persistSession(
    AuthSession session, {
    bool resetOnboarding = false,
  }) async {
    await _applyUser(session.user, accessToken: session.accessToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await _secureStorage.writeAccessToken(session.accessToken);

    if (resetOnboarding && session.user.id.isNotEmpty) {
      await prefs.remove(_onboardingKeyFor(session.user.id));
      _hasCompletedPreferenceOnboarding = false;
      notifyListeners();
    }
  }

  Future<void> _applyUser(
    AuthUser user, {
    String? accessToken,
    bool keepToken = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
    await prefs.setString('firstnames', user.firstnames);
    await prefs.setString('lastnames', user.lastnames);
    await prefs.setString('fullName', user.name);
    await prefs.setString('userEmail', user.emailAddress);
    await prefs.setString('phoneNumber', user.phoneNumber ?? '');
    await prefs.setString('role', user.role.apiValue);
    await prefs.setString(
      'defaultRoutePreference',
      user.defaultRoutePreference.apiValue,
    );

    _hasCompletedPreferenceOnboarding =
        prefs.getBool(_onboardingKeyFor(user.id)) ?? false;

    if (accessToken != null) {
      await _secureStorage.writeAccessToken(accessToken);
    }

    _isLoggedIn = true;
    if (accessToken != null) {
      _accessToken = accessToken;
    } else if (!keepToken) {
      _accessToken = null;
    }
    _userId = user.id;
    _firstnames = user.firstnames;
    _lastnames = user.lastnames;
    _fullName = user.name;
    _userEmail = user.emailAddress;
    _phoneNumber = user.phoneNumber;
    _role = user.role;
    _defaultRoutePreference = user.defaultRoutePreference;
    _defaultBikeProfile = user.defaultBikeProfile;
    _voiceGuidanceEnabled = user.voiceGuidanceEnabled;
    _voiceLanguage = user.voiceLanguage;
    _distanceUnit = user.distanceUnit;
    _lastApiError = null;
    notifyListeners();
  }

  Future<void> agreeToTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('agreedToTerms', true);
    _agreedToTerms = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final preservedOnboarding = <String, bool>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith('onboarding_')) {
        preservedOnboarding[key] = prefs.getBool(key) ?? false;
      }
    }

    await prefs.clear();
    for (final entry in preservedOnboarding.entries) {
      await prefs.setBool(entry.key, entry.value);
    }
    await _secureStorage.clearAll();
    _isLoggedIn = false;
    _accessToken = null;
    _userId = null;
    _firstnames = null;
    _lastnames = null;
    _fullName = null;
    _userEmail = null;
    _phoneNumber = null;
    _role = UserRole.user;
    _defaultRoutePreference = RoutePreference.recommended;
    _defaultBikeProfile = BikeProfile.urban;
    _voiceGuidanceEnabled = true;
    _voiceLanguage = VoiceLanguageOption.system;
    _distanceUnit = DistanceUnit.kilometers;
    _agreedToTerms = false;
    _hasCompletedPreferenceOnboarding = false;
    if (!_sessionExpired) {
      _lastApiError = null;
    }
    notifyListeners();
  }
}
