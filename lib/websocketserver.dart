import 'dart:io';

import 'package:StreamHeckServer/globals.dart';
import 'package:process_run/shell.dart';
import 'package:socket_io/socket_io.dart';

Shell shell = Shell();
String pastes = Globals.pastes;

WebSocketServer() {
  start();
}

void start() async {
  var io = Server();

  io.on('connection', (client) {
    print('Socket Server Connected');
    client.on('pasteline', (data) => paste(data));
    client.on('hotkey', (data) => hotKey(data));
  });

  io.listen(3003);
}

void hotKey(String data) async {
  var formatted = '+^%($data)';
  Process.runSync(
    'powershell',
    [
      r'$wshell = New-Object -ComObject wscript.shell;'
          "\$wshell.SendKeys('$formatted')"
    ],
  );
}

void paste(String data) {
  var tic = DateTime.now().millisecondsSinceEpoch;

  Process.runSync(
      'powershell',
      [
        'Get-Content $data | Set-Clipboard;'
            r'$wshell = New-Object -ComObject wscript.shell;'
            "\$wshell.SendKeys('^v');"
      ],
      workingDirectory:
          r'C:\Users\yupni\AllCode\MyCode\StreamHeckServer\bin\paste');

  var toc = DateTime.now().millisecondsSinceEpoch;
  var time = toc - tic;
  print('Paste Took: $time ms');
}

// https://superuser.com/questions/1455857/how-to-disable-office-key-keyboard-shortcut-opening-office-app
