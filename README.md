# Android Print Service

Flutter plugin to print documents on Android devices using native print service.  
This plugin supports both sharing documents while the app is running and when the app is closed.

---

## Features

- Receive documents shared from other apps.
- Preview received files inside your Flutter app.
- Works on Android with proper system alert window permission.

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  android_printer_service: ^0.0.2
```

## Demo

![Android Print Service Demo](https://github.com/duypxd/android_print_service/raw/main/Demo.gif)

## Usage

Below is a concise example showing how to handle shared documents and preview them:

```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_printer_service/android_printer_service.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription _forwardPrintStreamSubs;
  String pathFile = '';

  @override
  void initState() {
    super.initState();

    // 1. Wait for the widget tree to finish building
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2. Request System Alert Window permission
      _requestPermissionSystemAlert();

      // 3. Delay before starting to listen to document stream
      Future.delayed(const Duration(milliseconds: 320), () {
        _onForwardPrintStreamSubs();
      });
    });
  }

  // 4. Listen to shared documents
  void _onForwardPrintStreamSubs() {
    // Set the printer service name
    ForwardPrinter.setPrinterName("My_Printer_Service");

    // a) Listen for documents while the app is running
    _forwardPrintStreamSubs = ForwardPrinter.getDocumentStream().listen(
      _onForwardFile,
    );

    // b) Receive document if the app was just launched (previously closed)
    ForwardPrinter.getInitialDocument().then(_onForwardFile);
  }

  // 5. Handle received file
  void _onForwardFile(String? jsonStr) {
    if (jsonStr == null) return;

    final file = PrintFile.fromJson(jsonDecode(jsonStr));

    _onPreviewFiles([file.path]);
  }

  // 6. Display the file inside the app
  void _onPreviewFiles(List<String> paths) async {
    setState(() {
      pathFile = paths.first; // preview only the first file
    });
  }

  // 7. Request System Alert Window permission
  Future<void> _requestPermissionSystemAlert() async {
    if (Platform.isAndroid && context.mounted) {
      final status = await Permission.systemAlertWindow.status;
      if (status != PermissionStatus.granted) {
        final allow = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
              "This app needs permission to run the Printer Service properly. Do you want to allow it?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Deny"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Allow"),
              ),
            ],
          ),
        );

        if (allow == true) {
          await Future.delayed(
            const Duration(milliseconds: 150),
            () => Permission.systemAlertWindow.request(),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    // 8. Cancel the stream when the widget is disposed
    _forwardPrintStreamSubs.cancel();
    super.dispose();
  }
}
```

## Donate

If you find this plugin useful and want to support development, you can donate:

**Scan QR code:**

![Donate QR](https://raw.githubusercontent.com/duypxd/android_print_service/main/donate.jpeg)

**Or copy & send via Crypto:**

```
TYgEZMKdFYaVKm3iuHVRYXxnEQScqWoatP
```
