class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException({
    required this.message,
    this.code,
  });
}

class CacheException implements Exception {
  final String message;
  final String? code;

  CacheException({
    required this.message,
    this.code,
  });
}

class NetworkException implements Exception {
  final String message;
  final String? code;

  NetworkException({
    required this.message,
    this.code,
  });
}

class ValidationException implements Exception {
  final String message;
  final String? code;

  ValidationException({
    required this.message,
    this.code,
  });
}

class UnauthorizedException implements Exception {
  final String message;
  final String? code;

  UnauthorizedException({
    required this.message,
    this.code,
  });
}

class NotFoundException implements Exception {
  final String message;
  final String? code;

  NotFoundException({
    required this.message,
    this.code,
  });
} 