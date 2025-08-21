import 'dart:async';

import 'package:flutter/services.dart';

/// Flutter interface for receiving documents forwarded from Android.
class ForwardPrinter {
  /// MethodChannel for calling methods on the Android plugin.
  static const MethodChannel _mChannel = MethodChannel(
    'forward_print/messages',
  );

  /// EventChannel for receiving streaming events from Android (forwarded documents).
  static const EventChannel _eventChannel = EventChannel(
    'forward_print/events-document',
  );

  /// Stream of JSON strings representing forwarded documents from Android.
  /// Subscribe to this to receive new documents while the app is running.
  static Stream<String> getDocumentStream() =>
      _eventChannel.receiveBroadcastStream().cast<String>();

  /// Get the initial document if the app was started from a forwarded file.
  static Future<String?> getInitialDocument() async {
    final methodChannel = MethodChannel('forward_print/messages');
    final value = await methodChannel.invokeMethod<String>(
      'getInitialDocument',
    );
    return value;
  }

  /// Reset the plugin's stored documents.
  static void reset() {
    _mChannel.invokeMethod('reset').then((_) {});
  }
}

/// Model representing a forwarded print file.
class PrintFile {
  /// The absolute path of the file on the device.
  final String path;

  PrintFile(this.path);

  /// Construct a PrintFile from a JSON map (received from Android).
  PrintFile.fromJson(Map<String, dynamic> json) : path = json['path'];
}
