import 'package:cyclerisk/core/contracts/api_contracts.dart';
import 'package:cyclerisk/core/services/api_client.dart';
import 'package:cyclerisk/core/services/app_api_client.dart';
import 'package:cyclerisk/features/auth/data/models/auth_session.dart';

class AuthApiService implements AuthApiContract {
  AuthApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? AppApiClient.create();

  final ApiClient _apiClient;

  Future<AuthSession> register({
    required String firstnames,
    required String lastnames,
    required String emailAddress,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final json = await _apiClient.post(
      '/auth/register',
      body: {
        'firstnames': firstnames,
        'lastnames': lastnames,
        'email_address': emailAddress,
        'phone_number': phoneNumber,
        'password': password,
        'confirm_password': confirmPassword,
      },
    );

    return AuthSession.fromJson(json);
  }

  Future<AuthSession> login({
    required String emailAddress,
    required String password,
  }) async {
    final json = await _apiClient.post(
      '/auth/login',
      body: {'email_address': emailAddress, 'password': password},
    );

    return AuthSession.fromJson(json);
  }

  Future<String> forgotPassword({required String emailAddress}) async {
    final json = await _apiClient.post(
      '/auth/forgot-password',
      body: {'email_address': emailAddress},
    );

    return json['message']?.toString() ??
        'If the email is registered, a reset code has been sent.';
  }

  Future<String> resetPassword({
    required String emailAddress,
    required String code,
    required String newPassword,
  }) async {
    final json = await _apiClient.post(
      '/auth/reset-password',
      body: {
        'email_address': emailAddress,
        'code': code,
        'new_password': newPassword,
      },
    );

    return json['message']?.toString() ?? 'Password updated successfully.';
  }
}
