import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:cyclerisk/core/config/app_config.dart';
import 'package:cyclerisk/core/services/api_error_keys.dart';
import 'package:cyclerisk/core/services/api_exception.dart';

typedef UnauthorizedCallback = void Function();

class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
    this.onUnauthorized,
  }) : _client = client ?? http.Client(),
       _baseUrl = (baseUrl ?? AppConfig.apiBaseUrl).replaceAll(
         RegExp(r'/+$'),
         '',
       );

  final http.Client _client;
  final String _baseUrl;
  final UnauthorizedCallback? onUnauthorized;

  Future<Map<String, dynamic>> get(
    String path, {
    String? accessToken,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      _uri(path, queryParameters),
      headers: _headers(accessToken),
    );

    return _decodeMap(response);
  }

  Future<dynamic> getRaw(
    String path, {
    String? accessToken,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      _uri(path, queryParameters),
      headers: _headers(accessToken),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers(accessToken),
      body: jsonEncode(body),
    );

    return _decodeMap(response);
  }

  Future<dynamic> postRaw(
    String path, {
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    final response = await _client.post(
      _uri(path),
      headers: _headers(accessToken),
      body: jsonEncode(body),
    );

    return _decode(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    final response = await _client.patch(
      _uri(path),
      headers: _headers(accessToken),
      body: jsonEncode(body),
    );

    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    String? accessToken,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.delete(
      _uri(path, queryParameters),
      headers: _headers(accessToken),
    );

    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    String? accessToken,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(_headers(accessToken));
    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    return _decodeMap(response);
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$_baseUrl$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters);
  }

  Map<String, String> _headers(String? accessToken) {
    return {
      'accept': 'application/json',
      'content-type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'authorization': 'Bearer $accessToken',
    };
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    final decoded = _decode(response);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object response');
    }

    return decoded;
  }

  dynamic _decode(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) {
        onUnauthorized?.call();
      }

      final message = _errorMessage(decoded, response.statusCode);
      throw ApiException(
        message.rawMessage,
        statusCode: response.statusCode,
        errorKey: message.errorKey,
      );
    }

    return decoded;
  }

  _ApiErrorPayload _errorMessage(dynamic decoded, int statusCode) {
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'];
      if (message is String && message.isNotEmpty) {
        return _ApiErrorPayload(rawMessage: message);
      }
      if (message is List && message.isNotEmpty) {
        return _ApiErrorPayload(rawMessage: message.first.toString());
      }
    }

    if (statusCode == 502) {
      return const _ApiErrorPayload(errorKey: ApiErrorKeys.serviceUnavailable);
    }
    if (statusCode == 429) {
      return const _ApiErrorPayload(errorKey: ApiErrorKeys.tooManyRequests);
    }
    if (statusCode == 403) {
      return const _ApiErrorPayload(errorKey: ApiErrorKeys.insufficientRole);
    }
    if (statusCode == 401) {
      return const _ApiErrorPayload(errorKey: ApiErrorKeys.sessionExpired);
    }

    return const _ApiErrorPayload(errorKey: ApiErrorKeys.requestFailed);
  }
}

class _ApiErrorPayload {
  const _ApiErrorPayload({this.rawMessage = '', this.errorKey});

  final String rawMessage;
  final String? errorKey;
}
