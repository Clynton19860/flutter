import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _definedApiUrl = String.fromEnvironment('API_URL');

// Chrome cannot reach the Android emulator's host alias; pick a sane default
// per platform, still overridable with --dart-define=API_URL=...
String get _defaultApiUrl =>
    kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

String get apiBaseUrl =>
    _definedApiUrl.isNotEmpty ? _definedApiUrl : _defaultApiUrl;

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      headers: {'Accept': 'application/json'},
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
  return dio;
});
