import 'dart:io';
import 'package:win32_registry/win32_registry.dart';

class WindowsUrlSchemeRegistrar {
  static Future<void> registerScheme(String scheme) async {
    if (!Platform.isWindows) return;

    try {
      String appPath = Platform.resolvedExecutable;

      String protocolRegKey = 'Software\\Classes\\$scheme';
      RegistryValue protocolRegValue = const RegistryValue(
        'URL Protocol',
        RegistryValueType.string,
        '',
      );
      String protocolCmdRegKey = 'shell\\open\\command';
      RegistryValue protocolCmdRegValue = RegistryValue(
        '',
        RegistryValueType.string,
        '"$appPath" "%1"',
      );

      final regKey = Registry.currentUser.createKey(protocolRegKey);
      regKey.createValue(protocolRegValue);
      regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);

      print('Successfully registered URL scheme: $scheme://');
    } catch (e) {
      print('Failed to register URL scheme: $e');
    }
  }
}