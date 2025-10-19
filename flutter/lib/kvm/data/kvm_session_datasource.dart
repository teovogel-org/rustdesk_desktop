import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KVMSessionDatasource {
  final _storage = FlutterSecureStorage();

  final refreshTokenStorageKey = "refreshTokenStorageKey";

  final loginEmailStorageKey = "loginEmailStorageKey";
  final loginPasswordStorageKey = "loginPasswordStorageKey";

  final deviceIdStorageKey = "deviceIdStorageKey";

  Future<String?> getRefreshToken() => _get(refreshTokenStorageKey);
  void storeRefreshToken(String? token) {
    _store(refreshTokenStorageKey, token);
  }

  Future<String?> getLoginEmail() => _get(loginEmailStorageKey);
  void storeLoginEmail(String? emaiil) {
    _store(loginEmailStorageKey, emaiil);
  }

  Future<String?> getLoginPassword() => _get(loginPasswordStorageKey);
  void storeLoginPassword(String? password) {
    _store(loginPasswordStorageKey, password);
  }

  Future<int?> getDeviceId() async {
    final deviceIdString = await _get(deviceIdStorageKey);
    return deviceIdString != null ? int.parse(deviceIdString) : null;
  }

  void storeDeviceId(int? deviceId) {
    _store(deviceIdStorageKey, deviceId?.toString());
  }

  void _store(String key, String? value) {
    _storage.write(key: key, value: value);
  }

  Future<String?> _get(String key) {
    return _storage.read(key: key);
  }
}
