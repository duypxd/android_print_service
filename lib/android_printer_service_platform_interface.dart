import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'android_printer_service_method_channel.dart';

abstract class AndroidPrinterServicePlatform extends PlatformInterface {
  /// Constructs a AndroidPrinterServicePlatform.
  AndroidPrinterServicePlatform() : super(token: _token);

  static final Object _token = Object();

  static AndroidPrinterServicePlatform _instance = MethodChannelAndroidPrinterService();

  /// The default instance of [AndroidPrinterServicePlatform] to use.
  ///
  /// Defaults to [MethodChannelAndroidPrinterService].
  static AndroidPrinterServicePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AndroidPrinterServicePlatform] when
  /// they register themselves.
  static set instance(AndroidPrinterServicePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
