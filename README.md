# StreamHeck Server
The server side of StreamHeck (client/server) system.  
The client-side code can be found [here](https://github.com/Bluebar1/StreamHeckApp).

## HTTP server (fileserver.dart)
On startup, a VirtualDirectory is created and checks if the files it needs exist.
```dart
new File('$route/macros.json').createSync(recursive: true);
```
Then the server is started and listens for requests from the client
```dart
try {
    server = await HttpServer.bind(InternetAddress.anyIPv4, 4044);
  } catch (e) {
    print("Couldn't bind to port 4044: $e");
    exit(-1);
  }
```
The runPost function has 3 possible routes:
* Create new page
* Add macro to page
* Upload image file (used for decoration of buttons)

Uploading an image requires me to convert the request to an int array and using MimeMultipartTransformer to create a new image from bytes.
```dart
var dataBytes = <int>[];
await for (var data in request) {
  dataBytes.addAll(data);
}

var boundary = request.headers.contentType.parameters['boundary'];
final transformer = MimeMultipartTransformer(boundary);
final streamBody = Stream.fromIterable([dataBytes]);
final parts = await transformer.bind(streamBody).toList();  
```

The runGet function has 2 possible routes:
* Get an image from the bin/img/
* Get json file of macros from the bin/pages/ directory.

Here is how it serves an image:
```dart
if (req.uri.pathSegments[0].contains('image_picker')) {
  var _fileName = req.uri.pathSegments[0];
  vd.serveFile(File('bin/img/$_fileName'), req);
  return;
}
```

## Socket Server (websocketserver.dart)
The socket servers sole purpose is to listen for the user triggering one of the macros in the app. The signal recieved contains one of 3 labels:
* HotKey
* Command
* Paste

Here is an example of "Paste" being called:
```dart
void paste(String data) {
  
  Process.runSync(
      'powershell',
      [
        'Get-Content $data | Set-Clipboard;'
            r'$wshell = New-Object -ComObject wscript.shell;'
            "\$wshell.SendKeys('^v');"
      ],
      workingDirectory:
          r'C:\Users\yupni\AllCode\MyCode\StreamHeckServer\bin\paste');
  }
```
