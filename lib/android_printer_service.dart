import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class ForwardPrinter {
  static const MethodChannel _mChannel = MethodChannel(
    'forward_print/messages',
  );
  static const EventChannel _eChannelDocument = EventChannel(
    'forward_print/events-document',
  );

  static Stream<PrintFile>? _streamDocument;

  static Future<PrintFile?> getInitialDocument() async {
    final json = await _mChannel.invokeMethod('getInitialDocument');
    if (json == null) return null;
    final encoded = jsonDecode(json);
    return PrintFile.fromJson(encoded);
  }

  static Stream<PrintFile> getDocumentStream() {
    if (_streamDocument == null) {
      final stream = _eChannelDocument
          .receiveBroadcastStream('document')
          .cast<String?>();
      _streamDocument = stream.transform(
        StreamTransformer.fromHandlers(
          handleData: (String? data, EventSink<PrintFile> sink) {
            if (data != null) {
              final encoded = jsonDecode(data);
              final file = PrintFile.fromJson(encoded);
              sink.add(file);
            }
          },
        ),
      );
    }
    return _streamDocument!;
  }

  static void reset() {
    _mChannel.invokeMethod('reset').then((_) {});
  }
}

class PrintFile {
  final String path;

  PrintFile(this.path);

  PrintFile.fromJson(Map<String, dynamic> json) : path = json['path'];
}
