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
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

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
        // TODO: debug ref(clockProvider)
        'id': 'q-${ref.read(clockProvider)().millisecondsSinceEpoch}',
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
