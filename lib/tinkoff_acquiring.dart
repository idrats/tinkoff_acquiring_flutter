import 'package:flutter/services.dart';

class TinkoffAcquiring {
  static const MethodChannel _channel =
      const MethodChannel('tinkoff_acquiring');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get openPaymentScreen async {
    final String result = await _channel.invokeMethod('openPaymentScreen');
    return result;
  }
}
