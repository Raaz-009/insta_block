import 'package:flutter/services.dart';

/// Bridge to the Android-only Instagram app and DNS protection services.
/// Protection is best-effort and requires the user to grant Android permissions.
class ProtectionService {
  static const _channel = MethodChannel('com.reboot/blocking');

  Future<Map<String, dynamic>> start(DateTime expiresAt) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'startProtection',
      {'expiresAt': expiresAt.millisecondsSinceEpoch},
    );
    return result ?? <String, dynamic>{};
  }

  Future<void> stop() => _channel.invokeMethod<void>('stopProtection');
  Future<void> openAccessibilitySettings() =>
      _channel.invokeMethod<void>('openAccessibilitySettings');

  Future<Map<String, dynamic>> status() async =>
      (await _channel.invokeMapMethod<String, dynamic>('getProtectionStatus')) ??
      <String, dynamic>{};
}

final protectionService = ProtectionService();
