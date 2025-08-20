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
  android_printer_service: ^0.0.1
```

## Demo

![Android Print Service Demo](ScreenRecording.gif)

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
  // Subscription to listen for documents shared while app is in memory
  late StreamSubscription<PrintFile?> _subscription;

  // Store path of received file
  String pathFile = '';

  @override
  void initState() {
    super.initState();
    // Wait until first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request permission for system alert window (needed on Android)
      _requestSystemAlertPermission();

      // Delay a bit then start listening for shared documents
      Future.delayed(const Duration(milliseconds: 320), _listenSharedDocs);
    });
  }

  // Listen to documents shared while app is running and get initial document if app was closed
  void _listenSharedDocs() {
    _subscription = ForwardPrinter.getDocumentStream().listen(_onFileReceived);
    ForwardPrinter.getInitialDocument().then(_onFileReceived);
  }

  // Handle received file
  void _onFileReceived(PrintFile? file) {
    if (file?.path != null) {
      setState(() {
        pathFile = file!.path; // Update UI with received file path
      });
    }
  }

  // Request Android system alert window permission if not granted
  Future<void> _requestSystemAlertPermission() async {
    if (!Platform.isAndroid) return; // Only needed on Android
    final status = await Permission.systemAlertWindow.status;
    if (status != PermissionStatus.granted && context.mounted) {
      Future.delayed(
        const Duration(milliseconds: 150),
        () async => await Permission.systemAlertWindow.request(),
      );
    }
  }

  @override
  void dispose() {
    _subscription.cancel(); // Cancel stream subscription to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Android Print Service Demo')),
      body: Center(
        child: pathFile.isEmpty
            ? const Text('No file received') // Show message if no file
            : Text('Received file: $pathFile'), // Display received file path
      ),
    );
  }
}
```
