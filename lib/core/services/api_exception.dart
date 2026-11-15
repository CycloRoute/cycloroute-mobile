class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.errorKey,
    this.detail,
  });

  final String message;
  final int? statusCode;
  final String? errorKey;
  final String? detail;

  factory ApiException.connectFailed() {
    return const ApiException('', errorKey: 'connect_failed');
  }

  factory ApiException.serviceUnavailable() {
    return const ApiException(
      '',
      statusCode: 502,
      errorKey: 'service_unavailable',
    );
  }

  @override
  String toString() => message;
}
