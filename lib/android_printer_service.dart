
import 'android_printer_service_platform_interface.dart';

class AndroidPrinterService {
  Future<String?> getPlatformVersion() {
    return AndroidPrinterServicePlatform.instance.getPlatformVersion();
  }
}
