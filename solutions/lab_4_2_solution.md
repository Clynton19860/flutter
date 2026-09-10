# LAB 4.2 · Real quote API with dio

`FakeQuoteService` is swapped for a real HTTP call, in one provider line. Transport errors become messages a customer can read.

**This lab was demonstrated on the projector, not typed.** The full branch is
`lab-4-2-solution` — `git checkout lab-4-2-solution`. The files below are what changed.

## Files changed

| | File |
|---|---|
| changed | `android/app/src/main/AndroidManifest.xml` |
| new | `lib/core/network/dio_client.dart` |
| new | `lib/features/quote/data/dio_quote_service.dart` |
| changed | `lib/features/quote/domain/quote_model.dart` |
| new | `lib/features/quote/domain/quote_model.g.dart` |
| changed | `lib/features/quote/presentation/quote_providers.dart` |
| changed | `pubspec.lock` |
| changed | `pubspec.yaml` |
| new | `test/dio_service_test.dart` |
| new | `tool/mock_server.dart` |

## `lib/core/network/dio_client.dart`

```dart
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
```

## `lib/features/quote/data/dio_quote_service.dart`

```dart
import 'package:dio/dio.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class DioQuoteService implements QuoteService {
  DioQuoteService(this._dio);
  final Dio _dio;

  @override
  Future<Quote> getQuote(QuoteRequest request) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/quote',
        data: request.toJson(),
      );
      return Quote.fromJson(res.data!);
    } on DioException catch (e) {
      throw QuoteException(_message(e));
    }
  }

  /// Turns "SocketException: Connection refused" into something a customer
  /// can read. This is the only place that knows about transport errors.
  String _message(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'The server took too long. Check your connection.',
        DioExceptionType.connectionError => 'Cannot reach the quote service.',
        DioExceptionType.badResponse => switch (e.response?.statusCode) {
            422 => (e.response?.data as Map?)?['message'] as String? ??
                'Invalid request',
            _ => 'Server error (${e.response?.statusCode})',
          },
        _ => 'Unexpected error: ${e.message}',
      };
}

/// toString() returns the bare message, so the notifier's
/// `e.toString().replaceFirst('Exception: ', '')` shows clean text.
class QuoteException implements Exception {
  QuoteException(this.message);
  final String message;

  @override
  String toString() => message;
}
```

## `lib/features/quote/presentation/quote_providers.dart`

```dart
// No package:flutter/material.dart import in this file. That is the boundary
// between logic and UI, and it is what keeps the test below fast.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/network/dio_client.dart';
import 'package:quote_app/features/quote/data/dio_quote_service.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

// The one line that swaps fake for real. Nothing else in the app changes.
final quoteServiceProvider =
    Provider<QuoteService>((ref) => DioQuoteService(ref.watch(dioProvider)));

class QuoteNotifier extends Notifier<QuoteState> {
  @override
  QuoteState build() => const QuoteIdle();

  Future<void> submit(QuoteRequest request) async {
    state = const QuoteLoading();
    try {
      final quote = await ref.read(quoteServiceProvider).getQuote(request);
      state = QuoteLoaded(quote);
    } catch (e) {
      state = QuoteFailed(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const QuoteIdle();
}

final quoteProvider =
    NotifierProvider<QuoteNotifier, QuoteState>(QuoteNotifier.new);
```

## `tool/mock_server.dart`

```dart
// A zero-dependency mock quote API. Run it in a second terminal:
//   dart run tool/mock_server.dart
//
// Reach it from:
//   Android emulator -> http://10.0.2.2:8080   (10.0.2.2 is the host machine)
//   iOS simulator    -> http://localhost:8080
//   Physical phone   -> http://<laptop LAN IP>:8080  (same Wi-Fi)
//   Chrome           -> http://localhost:8080
import 'dart:convert';
import 'dart:io';

const _port = 8080;

double _premium(Map<String, dynamic> r) {
  var p = 1000.0;
  final age = (r['driverAge'] as num).toInt();
  final year = (r['year'] as num).toInt();
  if (age < 25) p *= 1.5;
  if (year < 2015) p *= 1.2;
  p *= switch (r['cover'] as String?) {
        'thirdParty' => 0.6,
        'thirdPartyFireTheft' => 0.8,
        _ => 1.0,
      };
  return (p * 100).roundToDouble() / 100;
}

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
  stdout.writeln('Mock quote API listening on http://localhost:$_port');
  stdout.writeln('Android emulator reaches it at http://10.0.2.2:$_port');

  await for (final req in server) {
    final res = req.response..headers.contentType = ContentType.json;

    if (req.method == 'GET' && req.uri.path == '/health') {
      res.write(jsonEncode({'status': 'ok'}));
      await res.close();
      continue;
    }

    if (req.method != 'POST' || req.uri.path != '/quote') {
      res.statusCode = HttpStatus.notFound;
      res.write(jsonEncode({'message': 'Not found'}));
      await res.close();
      continue;
    }

    try {
      final body = jsonDecode(await utf8.decoder.bind(req).join())
          as Map<String, dynamic>;
      await Future<void>.delayed(const Duration(milliseconds: 800));

      final year = (body['year'] as num).toInt();
      if (year < 2000) {
        res.statusCode = 422;
        res.write(jsonEncode({'message': 'Vehicle too old to insure'}));
        await res.close();
        continue;
      }

      res.write(jsonEncode({
        'id': 'q-${DateTime.now().millisecondsSinceEpoch}',
        'premium': _premium(body),
        'currency': 'ZAR',
        'breakdown_lines': [
          'Base premium',
          if (body['driverAge'] as int < 25) 'Young driver loading',
          if (year < 2015) 'Vehicle age loading',
        ],
      }));
      await res.close();
    } catch (e) {
      res.statusCode = HttpStatus.badRequest;
      res.write(jsonEncode({'message': 'Malformed request: $e'}));
      await res.close();
    }
  }
}
```

