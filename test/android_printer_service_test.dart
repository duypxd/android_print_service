import 'package:flutter_test/flutter_test.dart';
import 'package:android_printer_service/android_printer_service.dart';
import 'package:android_printer_service/android_printer_service_platform_interface.dart';
import 'package:android_printer_service/android_printer_service_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAndroidPrinterServicePlatform
    with MockPlatformInterfaceMixin
    implements AndroidPrinterServicePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AndroidPrinterServicePlatform initialPlatform = AndroidPrinterServicePlatform.instance;

  test('$MethodChannelAndroidPrinterService is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAndroidPrinterService>());
  });

  test('getPlatformVersion', () async {
    AndroidPrinterService androidPrinterServicePlugin = AndroidPrinterService();
    MockAndroidPrinterServicePlatform fakePlatform = MockAndroidPrinterServicePlatform();
    AndroidPrinterServicePlatform.instance = fakePlatform;

    expect(await androidPrinterServicePlugin.getPlatformVersion(), '42');
  });
}
