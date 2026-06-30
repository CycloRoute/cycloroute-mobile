import 'package:cyclerisk/core/services/api_client.dart';

class AppApiClient {
  static UnauthorizedCallback? onUnauthorized;

  static ApiClient create({String? baseUrl}) {
    return ApiClient(baseUrl: baseUrl, onUnauthorized: onUnauthorized);
  }
}
