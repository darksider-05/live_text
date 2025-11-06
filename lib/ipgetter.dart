import 'package:flutter/services.dart';

/// Provides access to the device's local IPv4 address via the native platform channel.
class LocalIp {
  static const MethodChannel _channel = MethodChannel(
    'com.github.darksider_05.livetext.live_text.live_text/ip',
  );

  /// Returns the local IPv4 address (e.g. "192.168.43.1"), or "0.0.0.0" on failure.
  static Future<String> get() async {
    try {
      final ip = await _channel.invokeMethod<String>('getLocalIPv4');
      return ip ?? '0.0.0.0';
    } catch (_) {
      return '0.0.0.0';
    }
  }
}
