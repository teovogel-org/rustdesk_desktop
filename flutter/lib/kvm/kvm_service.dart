import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/kvm/constants.dart';
import 'package:flutter_hbb/kvm/data/kvm_api.dart';
import 'package:flutter_hbb/kvm/domain/kvm_state_provider.dart';
import 'package:flutter_hbb/kvm/kvm_utils.dart';
import 'package:flutter_hbb/kvm/windows_url_registrar.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:get/get.dart';

class KVMService {
  static final KVMService _instance = KVMService._internal();

  KVMService._internal();

  factory KVMService() => _instance;

  final model = gFFI.serverModel;

  String? lastKnownRustId;
  String? lastKnownRustPass;
  DateTime lastHeartBeatTimestamp = DateTime.now();

  late KVMStateProvider kvmState;

  int? heartbeatS;

  void start(KVMStateProvider kvmState) async {
    this.kvmState = kvmState;
    setHeartbeatRefreshRate();
  }

  Future<void> initAppLinks(Function(String) handleDeepLink) async {
    final appLinks = AppLinks();

    // Register URL scheme on Windows
    if (Platform.isWindows) {
      await WindowsUrlSchemeRegistrar.registerScheme('dexremote');
    }

    try {
      // Handle deep links when app is already running
      appLinks.uriLinkStream.listen((uri) {
        handleDeepLink(uri.toString());
      });

      // Handle deep links when app is opened from closed state
      final Uri? initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        handleDeepLink(initialUri.toString());
      }
    } catch (e) {
      // Handle exception by ignoring it (as requested - no error handling)
    }
  }

  static void setHeartbeatRefreshRate() {
    platformFFI.invokeMethod(
      AndroidKVMChannel.kSetHeartbeatRefreshRate,
      kHeartbeatDefaultRefreshRate,
    );
  }

  static Future<String?> getMacAddress() async {
    return await platformFFI.invokeMethod(AndroidKVMChannel.kGetMacAddres);
  }

  static Future<String?> getAndroidId() async {
    return await platformFFI.invokeMethod(AndroidKVMChannel.kGetAndroidId);
  }

  static Future<String?> getSerialNo() async {
    return await platformFFI.invokeMethod(AndroidKVMChannel.kGetSerialNo);
  }

  static Future<String?> getKVMId() async {
    return await platformFFI.invokeMethod(AndroidKVMChannel.kGetKVMId);
  }

  void checkCredentialsAndSendHeartBeat() {
    if (model.isStart) {
      final currentRustId = model.serverId.value.text.removeAllWhitespace;
      final currentRustPass = model.serverPasswd.value.text;

      String? sentRustId;
      String? sentRustPass;
      if (lastKnownRustId != currentRustId ||
          lastKnownRustPass != currentRustPass) {
        sentRustId = currentRustId;
        sentRustPass = currentRustPass;
      }
      var credentialsChanged = sentRustId != null || sentRustPass != null;
      var shouldSendHeartBeat = credentialsChanged ||
          lastHeartBeatTimestamp.isBefore(DateTime.now().subtract(
            Duration(seconds: heartbeatS ?? defaultHeartbeatS),
          ));

      if (shouldSendHeartBeat) {
        sendHeartBeat(sentRustId, sentRustPass);
      }
    } else {
      debugPrint("KVM not seted up");
    }
  }

  void sendHeartBeat(String? sentRustId, String? sentRustPass) async {
    try {
      final heartbeatS = await KVMApi.heartbeat(
        kvmState.registeredDeviceId!,
        authToken: kvmState.authToken,
        rustId: sentRustId,
        rustPass: sentRustPass,
        memLoadMb: KVMUtils.getUsedRAMInMB(),
      );
      this.heartbeatS = heartbeatS;
      print("HEARTBEAT SENT");
      lastKnownRustId = sentRustId ?? lastKnownRustId;
      lastKnownRustPass = sentRustPass ?? lastKnownRustPass;
      lastHeartBeatTimestamp = DateTime.now();
    } on KVMAuthError {
      kvmState.onUserSessionExpired();
    } on KVMApiError {
      //
    }
  }

}
