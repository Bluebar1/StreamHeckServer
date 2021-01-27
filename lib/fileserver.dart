import 'dart:async';
import 'dart:convert' as convert;
import 'package:StreamHeckServer/globals.dart';
import 'package:http_server/http_server.dart';
import 'package:path/path.dart' as p;

import 'dart:io';

import 'package:mime/mime.dart';

import 'macro.dart';

// import 'package:path/path.dart' as p;

//File(p.join(p.dirname(Platform.script.toFilePath()), 'macros.json'));

VirtualDirectory vd;
String route = Globals.pages;

FileServer() {
  start();
}

Future start() async {

  if (!File('$route/macros.json').existsSync()) {
    print("file not found");
    new File('$route/macros.json').createSync(recursive: true);
  }

  vd = VirtualDirectory('.');

  var server;

  try {
    server = await HttpServer.bind(InternetAddress.anyIPv4, 4044);
  } catch (e) {
    print("Couldn't bind to port 4044: $e");
    exit(-1);
  }
  print('Listening on http://${server.address.address}:${server.port}/');

  await for (HttpRequest req in server) {
    print(req.requestedUri);
    print(req.method);
    print(req.headers);

    if (req.method == 'POST') {
      runPost(req);
    } else if (req.method == 'GET') {
      runGet(req);
    } else {
      print("Error: Unknown request method");
    }
  }
}

void runPost(HttpRequest req) async {
  print("===RUN POST CALLED" + req.headers['posttype'].last);
  if (req.headers['posttype'].last == 'addImage') {
    print('REQ POST TYPE IS ADDIMAGE');
    await addImage(req);
    return;
  }

  final contentType = req.headers.contentType;
  final response = req.response;

  if (contentType?.mimeType == 'application/json') {
    try {
      var fileName = '$route' +
          req.uri.toString().toLowerCase() +
          '.json'; //.pathSegments.last; /*4*/
      print("posting json");
      var macros = <Macro>[];
      var mjson = convert.jsonDecode(File(fileName).readAsStringSync()) as List;
      macros = mjson.map((e) => Macro.fromJson(e)).toList();

      final content = await convert.utf8.decoder.bind(req).join(); /*2*/
      var data = convert.jsonDecode(content) as Map; /*3*/
      macros.add(Macro.fromJson(data));

      await File(fileName).writeAsStringSync(convert.jsonEncode(macros));
      req.response
        ..statusCode = HttpStatus.ok
        ..write('Wrote data for ${data['name']}.');
    } catch (e) {
      print("CATCH ERROR REACHED : " + e.toString());
      response
        ..statusCode = HttpStatus.internalServerError
        ..write('Exception during file I/O: $e.');
    }
    await req.response.close();
  }
}

void runGet(HttpRequest req) async {
  print('RUN GET CALLED');
  if (req.uri.pathSegments[0].contains('image_picker')) {
    var _fileName = req.uri.pathSegments[0];
    vd.serveFile(File('bin/img/$_fileName'), req);
    return;
  }

  var targetFile = File('$route' + req.uri.toString());
  print('TARGET FILE PATH ::: ' + targetFile.path);
  if (await targetFile.exists()) {
    req.response.headers.add('Content-Type', 'text/html');
    try {
      await req.response.addStream(targetFile.openRead());
    } catch (e) {
      print("Couldn't read file: $e");
      exit(-1);
    }
  } else {
    print("Can't open ${targetFile.path}.");
    req.response.statusCode = HttpStatus.notFound;
  }
  await req.response.close();
}

void addImage(HttpRequest request) async {
  var dataBytes = <int>[];
  await for (var data in request) {
    dataBytes.addAll(data);
  }

  var boundary = request.headers.contentType.parameters['boundary'];
  final transformer = MimeMultipartTransformer(boundary);
  final streamBody = Stream.fromIterable([dataBytes]);
  final parts = await transformer.bind(streamBody).toList();

  for (var part in parts) {
    print(part.headers);
    final contentDisposition = part.headers['content-disposition'];
    final _nameFile =
        RegExp(r'filename="([^"]*)"').firstMatch(contentDisposition).group(1);
    final content = await part.toList();

    if (!Directory('bin/img').existsSync()) {
      await Directory('bin/img').create();
    }
    await File('bin/img/$_nameFile').writeAsBytes(content[0]);
  }
  await request.response.close();
}
