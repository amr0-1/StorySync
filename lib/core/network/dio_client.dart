import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL for the MangaDex API
const String _mangaDexBaseUrl = 'https://api.mangadex.org';

/// Connection timeout in milliseconds
const int _connectTimeout = 15000;

/// Receive timeout in milliseconds
const int _receiveTimeout = 30000;

/// Provider for the globally configured Dio HTTP client.
///
/// This client is pre-configured with:
/// - MangaDex API base URL
/// - Reasonable connection and receive timeouts
/// - Custom User-Agent header
/// - Request/Response logging in debug mode
///
/// Usage:
/// ```dart
/// final dio = ref.watch(dioClientProvider);
/// final response = await dio.get('/manga', queryParameters: {...});
/// ```
final dioClientProvider = Provider<Dio>((ref) {
  return _createDioClient();
});

/// Creates and configures the Dio client instance.
Dio _createDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: _mangaDexBaseUrl,
      connectTimeout: const Duration(milliseconds: _connectTimeout),
      receiveTimeout: const Duration(milliseconds: _receiveTimeout),
      headers: {
        'User-Agent': 'StorySync/1.2.0 (Flutter; Manga Tracker)',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    ),
  );

  // Add logging interceptor for debugging
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) {
        // Using assert to only log in debug mode
        assert(() {
          // ignore: avoid_print
          print('[DIO] $obj');
          return true;
        }());
      },
    ),
  );

  // Add error handling interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        // Transform common errors into more descriptive messages
        if (error.type == DioExceptionType.connectionTimeout) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              type: error.type,
              error:
                  'Connection timed out. Please check your internet connection.',
            ),
          );
        }

        if (error.type == DioExceptionType.receiveTimeout) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              type: error.type,
              error: 'Server took too long to respond. Please try again.',
            ),
          );
        }

        if (error.response?.statusCode == 429) {
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: DioExceptionType.badResponse,
              error: 'Rate limited. Please wait a moment before trying again.',
            ),
          );
        }

        return handler.next(error);
      },
    ),
  );

  return dio;
}

/// Extension methods for cleaner Dio error handling.
extension DioExceptionExt on DioException {
  /// Returns a user-friendly error message.
  String get userMessage {
    if (error is String) return error as String;

    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Please check your internet.';
      case DioExceptionType.badResponse:
        return _getStatusMessage(response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error.';
      case DioExceptionType.unknown:
        return 'An unexpected error occurred.';
    }
  }

  String _getStatusMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 429:
        return 'Too many requests. Please wait.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Request failed with status $statusCode.';
    }
  }
}
