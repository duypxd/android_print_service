import 'dart:async';
import 'dart:io';

import 'package:android_printer_service/android_printer_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Demo Forward Print Service'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription _forwardPrintStreamSubs;
  String pathFile = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissionSystemAlert();
      Future.delayed(const Duration(milliseconds: 320), () {
        _onForwardPrintStreamSubs();
      });
    });
  }

  void _onForwardPrintStreamSubs() {
    // For sharing images coming from outside the app while the app is in the memory
    _forwardPrintStreamSubs = ForwardPrinter.getDocumentStream().listen(
      _onForwardFile,
    );
    // For sharing images coming from outside the app while the app is closed
    ForwardPrinter.getInitialDocument().then(_onForwardFile);
  }

  void _onForwardFile(PrintFile? file) async {
    if (file?.path != null) {
      _onPreviewFiles([file!.path]);
    }
  }

  void _onPreviewFiles(List<String> paths) async {
    setState(() {
      pathFile = paths.first;
    });
  }

  Future<void> _requestPermissionSystemAlert() async {
    if (Platform.isAndroid) {
      final status = await Permission.systemAlertWindow.status;
      if (status != PermissionStatus.granted && context.mounted) {
        Future.delayed(
          const Duration(milliseconds: 150),
          () async => await Permission.systemAlertWindow.request(),
        );
      }
    }
  }

  @override
  void dispose() {
    _forwardPrintStreamSubs.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[const Text('file Name:'), Text(pathFile)],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
