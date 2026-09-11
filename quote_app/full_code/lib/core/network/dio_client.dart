import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compile-time config. Never hard-code environment URLs.
///   flutter run --dart-define=API_URL=http://10.0.2.2:8080
const apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8080', // Android emulator -> host machine
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {'Accept': 'application/json'},
  ));
  if (kDebugMode) {
    // Gated on debug so release builds never print insurance data.
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
  return dio;
});
