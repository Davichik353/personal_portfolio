import 'dart:async';
import 'dart:io';

const _mimeTypes = <String, String>{
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.jpeg': 'image/jpeg',
  '.jpg': 'image/jpeg',
  '.md': 'text/markdown; charset=utf-8',
  '.pdf': 'application/pdf',
  '.png': 'image/png',
  '.ttf': 'font/ttf',
  '.webp': 'image/webp',
};

Future<void> main(List<String> arguments) async {
  final shareOnNetwork = arguments.contains('--phone');
  final root = Directory('website/dist').absolute;
  if (!root.existsSync()) {
    stderr.writeln('Не найдена папка ${root.path}');
    exitCode = 1;
    return;
  }

  final address = shareOnNetwork
      ? InternetAddress.anyIPv4
      : InternetAddress.loopbackIPv4;
  final server = await HttpServer.bind(address, 5173);
  const localUrl = 'http://localhost:5173';

  stdout.writeln('Портфолио запущено: $localUrl');
  if (shareOnNetwork) {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    );
    for (final interface in interfaces) {
      for (final item in interface.addresses) {
        if (!item.isLoopback) {
          stdout.writeln('Для телефона: http://${item.address}:5173');
        }
      }
    }
  } else {
    stdout.writeln(
      'Для проверки на телефоне запусти: dart run tool/serve_portfolio.dart --phone',
    );
  }
  stdout.writeln('Для остановки нажми Ctrl+C.');
  await _openBrowser(localUrl);

  await for (final request in server) {
    await _serve(request, root);
  }
}

Future<void> _serve(HttpRequest request, Directory root) async {
  var path = Uri.decodeComponent(request.uri.path);
  if (path == '/') path = '/index.html';
  final rootPath = root.resolveSymbolicLinksSync();
  final candidate = File(
    '${root.path}${path.replaceAll('/', Platform.pathSeparator)}',
  );

  try {
    final resolved = candidate.resolveSymbolicLinksSync();
    if (!resolved.startsWith('$rootPath${Platform.pathSeparator}')) {
      request.response.statusCode = HttpStatus.forbidden;
    } else {
      final file = File(resolved);
      final dot = resolved.lastIndexOf('.');
      final extension = dot < 0 ? '' : resolved.substring(dot).toLowerCase();
      request.response.headers.contentType = ContentType.parse(
        _mimeTypes[extension] ?? 'application/octet-stream',
      );
      request.response.headers.set('Cache-Control', 'no-cache');
      await request.response.addStream(file.openRead());
    }
  } on FileSystemException {
    request.response.statusCode = HttpStatus.notFound;
    request.response.write('404 — файл не найден');
  } finally {
    await request.response.close();
  }
}

Future<void> _openBrowser(String url) async {
  try {
    if (Platform.isWindows) {
      await Process.start('cmd', ['/c', 'start', '', url], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.start('open', [url]);
    } else if (Platform.isLinux) {
      await Process.start('xdg-open', [url]);
    }
  } on ProcessException {
    // The URL is printed above when automatic browser opening is unavailable.
  }
}
