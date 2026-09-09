// These tests talk to the mock API. Start it first, in a second terminal:
//   dart run tool/mock_server.dart
// If it is not running they skip rather than fail, so `flutter test` stays green.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_app/features/quote/data/dio_quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

Future<bool> _mockIsRunning() async {
  try {
    final s = await Socket.connect('localhost', 8080,
        timeout: const Duration(milliseconds: 400));
    s.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

void main() {
  late bool up;
  setUpAll(() async => up = await _mockIsRunning());

  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080',
    connectTimeout: const Duration(seconds: 5),
  ));
  final svc = DioQuoteService(dio);
  const req = QuoteRequest(
      make: 'VW', year: 2020, driverAge: 30, cover: Cover.comprehensive);

  test('valid request returns a quote from the API', () async {
    if (!up) return markTestSkipped('mock_server.dart is not running');
    final q = await svc.getQuote(req);
    expect(q.premium, greaterThan(0));
    expect(q.currency, 'ZAR');
    expect(q.breakdown, isNotEmpty);
  });

  test('a 422 surfaces the server message, not a stack trace', () async {
    if (!up) return markTestSkipped('mock_server.dart is not running');
    expect(() => svc.getQuote(req.copyWith(year: 1998)),
        throwsA(predicate((e) => e.toString() == 'Vehicle too old to insure')));
  });

  test('an unreachable server becomes a friendly message', () async {
    final bad = DioQuoteService(Dio(BaseOptions(
        baseUrl: 'http://localhost:9',
        connectTimeout: const Duration(seconds: 2))));
    expect(() => bad.getQuote(req),
        throwsA(predicate((e) => e.toString().contains('Cannot reach'))));
  });
}
