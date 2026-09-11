import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _definedApiUrl = String.fromEnvironment('API_URL');

// 10.0.2.2 is the Android emulator's alias for the host machine and only
// works there - Chrome, the iOS Simulator and macOS desktop all share the
// host's network directly and need plain localhost. Still overridable with
// --dart-define=API_URL=... for a physical device or a real API.
String get _defaultApiUrl => !kIsWeb && Platform.isAndroid
    ? 'http://10.0.2.2:8080'
    : 'http://localhost:8080';

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
