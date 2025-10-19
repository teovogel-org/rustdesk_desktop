

import 'package:flutter/material.dart';
import 'package:flutter_hbb/kvm/data/kvm_api.dart';
import 'package:flutter_hbb/kvm/data/kvm_session_datasource.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_device.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_folder.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_session.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_tenant.dart';
import 'package:flutter_hbb/kvm/kvm_utils.dart';
import 'package:flutter_hbb/kvm/presentation/kvm_state.dart';

class KVMStateProvider with ChangeNotifier {

  KVMStateProvider() {
    kvmSessionDatasource.getRefreshToken().then((refreshToken) async {
        int? deviceId = await kvmSessionDatasource.getDeviceId();
        if (refreshToken != null && deviceId != null) {
        try {
          KVMSession session = await _apiRequest(() {
              return KVMApi.refreshToken(
                deviceId.toString(),
                refreshToken,
              );
            });
          KVMDevice? device = await _apiRequest(() {
              return KVMApi.getDevice(
                deviceId,
                authToken: session.authToken,
              );
          });
          onSessionRestored(session, device);
          } on Exception catch (_) {}
        } else {
          onUserSessionExpired();
        }
      },
    );
  }

  final kvmSessionDatasource = KVMSessionDatasource();

  final loginStepState = KVMStepLogin();
  final registerDeviceStepState = KVMStepRegisterDevice();
  final requestPermissionsStepState = KVMStepRequestPerissions();
  KVMStepState nextStepState = KVMStepInitializing();

  KVMSession? session;
  KVMDevice? device;

  String? get authToken => session?.authToken;
  int? get registeredDeviceId => device?.id;

  bool get isKVMSetedup => session != null && device != null;

  void onUserSessionExpired() {
    _setSession(null);
    kvmSessionDatasource.storeLoginEmail(null);
    kvmSessionDatasource.storeLoginPassword(null);
    kvmSessionDatasource.storeDeviceId(null);
    nextStepState = loginStepState;
    notifyListeners();
  }

  void onSessionRestored(KVMSession session, KVMDevice? device) {
    _setSession(session);
    if (device != null) {
      onDeviceRegistered(device);
    } else {
      nextStepState = registerDeviceStepState;
      notifyListeners();
    }
  }

  void onLoginSuccess(
      KVMSession session, KVMDevice? device, String email, String password) {
    _setSession(session);
    kvmSessionDatasource.storeLoginEmail(email);
    kvmSessionDatasource.storeLoginPassword(password);
    kvmSessionDatasource.storeDeviceId(device?.id);
    nextStepState = registerDeviceStepState;
    notifyListeners();
  }

  void onRefreshToken(KVMSession session) {
    _setSession(session);
  }

  void _setSession(KVMSession? session) {
    this.session = session;
    kvmSessionDatasource.storeRefreshToken(session?.refreshToken);
  }

  void onDeviceRegistered(KVMDevice device) {
    this.device = device;
    kvmSessionDatasource.storeDeviceId(device.id);
    nextStepState = requestPermissionsStepState;
    notifyListeners();
  }

  Future<T> _apiRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on KVMAuthError catch (_) {
      onUserSessionExpired();
    } on KVMApiError catch (e) {
      return Future.error(e);
    }
    return Future.error(Exception("Algo salió mal"));
  }

  Future<KVMDevice?> login(String email, String password) async {
    return _apiRequest(() async {
      final (session, device) = await KVMApi.login(
        email,
        password,
        await KVMUtils.getSerialNO(),
      );
      this.device = device;
      onLoginSuccess(session, device, email, password);
      return device;
    });
  }

  Future<Iterable<KVMTenant>> fetchTenants() async {
    return _apiRequest(() {
      return KVMApi.getTenants(authToken: authToken);
    });
  }

  Future<KVMDevice> registerDevice(KVMFolder folder, String deviceName) async {
    final trimmedDeviceName = deviceName.trim();
    if (trimmedDeviceName.isEmpty) {
      return Future.error("El nombre no puede ser vacío");
    }
    return _apiRequest(() async {
      final device = await KVMApi.registerDevice(
        folder,
        trimmedDeviceName,
        await KVMUtils.getSerialNO(),
        authToken: authToken,
        soName: KVMUtils.getOSName(),
        soVersion: await KVMUtils.getOSVersion(),
        timeZone: DateTime.now().timeZoneName,
        localIps: await KVMUtils.getIPs(),
        macAddress: await KVMUtils.getMACs(), //does not work on Android
      );
      onDeviceRegistered(device);
      return device;
    });
  }
  
}
