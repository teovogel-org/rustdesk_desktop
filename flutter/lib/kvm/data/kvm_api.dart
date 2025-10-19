import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/kvm/constants.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_device.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_folder.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_session.dart';
import 'package:flutter_hbb/kvm/domain/models/kvm_tenant.dart';
import 'package:http/http.dart' as http;

abstract class KVMApi {
  static String getKVMApiUrl(String endpoint) => "$kvmApi/$endpoint";

  static Map<String, String> getKVMHttpHeaders(String? authToken) {
    return {'Authorization': 'Bearer $authToken'};
  }

  static Future<(KVMSession, KVMDevice?)> login(
      String username, String password, String serialNO) async {
    final endpoint = "auth/token?serial_number=$serialNO";
    try {
      Map<String, String> headers = {};
      headers['Content-Type'] = "application/x-www-form-urlencoded";
      final response = await http.post(
        Uri.parse(getKVMApiUrl(endpoint)),
        headers: headers,
        body: {"username": username, "password": password},
      );

      Map<String, dynamic> json = jsonDecode(response.body);
      if (response.statusCode == 200 && json.containsKey('access_token')) {
        final device = json['device'];
        return (
          KVMSession.fromJson(json),
          device != null ? KVMDevice.fromJson(device) : null
        );
      } else {
        throw KVMApiError(error: "${response.statusCode}: ${response.body}");
      }
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
  }

  static Future<KVMSession> refreshToken(
      String deviceId, String refreshToken) async {
    final endpoint = "auth/device/$deviceId/login";
    try {
      Map<String, String> headers = {};
      headers['Content-Type'] = "application/json";
      final response = await http.post(
        Uri.parse(getKVMApiUrl(endpoint)),
        headers: headers,
        body: jsonEncode({
          "refresh_token": refreshToken,
        }),
      );

      Map<String, dynamic> json = jsonDecode(response.body);
      if (response.statusCode == 200 && json.containsKey('access_token')) {
        return KVMSession.fromJson(json);
      } else {
        throw KVMApiError(error: "${response.statusCode}: ${response.body}");
      }
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
  }

  static Future<Iterable<KVMTenant>> getTenants({String? authToken}) async {
    final endpoint = "tenants/";
    try {
      var headers = getKVMHttpHeaders(authToken);
      headers['Content-Type'] = "application/x-www-form-urlencoded";
      final response = await http.get(
        Uri.parse(getKVMApiUrl(endpoint)),
        headers: headers,
      );

      if (response.body.contains("Authentication required.")) {
        throw KVMAuthError();
      }

      Map<String, dynamic> json = jsonDecode(response.body);
      if (response.statusCode == 200 && json.containsKey('items')) {
        return (json["items"] as Iterable<dynamic>)
            .map((e) => KVMTenant.fromJson(e));
      } else {
        throw KVMApiError(error: "${response.statusCode}: ${response.body}");
      }
    } on KVMAuthError catch (_) {
      rethrow;
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
  }

  static Future<Iterable<KVMFolder>> getFolders(int tenantId,
      {String? authToken}) async {
    final endpoint = "folders/";
    try {
      var headers = getKVMHttpHeaders(authToken);
      headers['Content-Type'] = "application/x-www-form-urlencoded";
      final response = await http.get(
        Uri.parse("${getKVMApiUrl(endpoint)}?tenant_id=$tenantId"),
        headers: headers,
      );

      if (response.body.contains("Authentication required.")) {
        throw KVMAuthError();
      }

      Map<String, dynamic> json = jsonDecode(response.body);
      if (response.statusCode == 200 && json.containsKey('items')) {
        return (json["items"] as Iterable<dynamic>)
            .map((e) => KVMFolder.fromJson(e));
      } else {
        throw KVMApiError(error: "${response.statusCode}: ${response.body}");
      }
    } on KVMAuthError catch (_) {
      rethrow;
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
  }

  static Future<KVMDevice> registerDevice(
    KVMFolder folder,
    String deviceName,
    String serialNO, {
    String? soName,
    String? soVersion,
    String? timeZone,
    String? localIps,
    Iterable<String>? macAddress,
    String? authToken,
  }) async {
    final endpoint = "devices/";
    try {
      var headers = getKVMHttpHeaders(authToken);
      headers['Content-Type'] = "application/json";
      final response = await http.post(Uri.parse(getKVMApiUrl(endpoint)),
          headers: headers,
          body: jsonEncode(
            {
              "name": deviceName,
              "ip_address": "",
              "mac_address": "",
              "id_rust": "",
              "pass_rust": "",
              "last_screenshot_path": "",
              "serial_number": serialNO,
              "folder_id": folder.id,
              "SO_name": soName,
              "SO_version": soVersion,
              "time_zone": timeZone,
              "local_ips": localIps,
              "MAC_adresses": macAddress,
              "os_kernel_version": "",
              "vendor_name": "",
              "vendor_model": "",
              "vendor_cores": 0,
              "vendor_ram_gb": 0
            },
          ));

      Map<String, dynamic> json = jsonDecode(response.body);
      if (response.statusCode == 200 && json.containsKey('id')) {
        return KVMDevice.fromJson(json);
      } else {
        throw KVMApiError(error: "${response.statusCode}: ${response.body}");
      }
    } on KVMAuthError catch (_) {
      rethrow;
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
  }

  static Future<KVMDevice?> getDevice(
    int? deviceId, {
    String? authToken,
  }) async {
    if (deviceId == null) {
      return null;
    }

    final endpoint = "devices/$deviceId";
    try {
      var headers = getKVMHttpHeaders(authToken);
      headers['Content-Type'] = "application/json";
      final response = await http.get(
        Uri.parse(getKVMApiUrl(endpoint)),
        headers: headers,
      );

      Map<String, dynamic> json = jsonDecode(response.body);
      if (response.statusCode == 200 && json.containsKey('id')) {
        return KVMDevice.fromJson(json);
      } else {
        throw KVMApiError(error: "${response.statusCode}: ${response.body}");
      }
    } on KVMAuthError catch (_) {
      rethrow;
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
  }

  static Future<int?> heartbeat(
    int deviceId, {
    String? rustId,
    String? rustPass,
    String? authToken, 
    int? memLoadMb,
  }) async {
    final endpoint = "devices/$deviceId/heartbeat";
    try {
      var headers = getKVMHttpHeaders(authToken);
      headers['Content-Type'] = "application/json";
      final response = await http.post(
        Uri.parse(getKVMApiUrl(endpoint)),
        headers: headers,
        body: rustId != null || rustPass != null
            ? jsonEncode(
                {
                  "id_rust": rustId,
                  "pass_rust": rustPass,
                  "MEM_load_mb": memLoadMb,
                },
              )
            : jsonEncode(
                {
                  "MEM_load_mb": memLoadMb,
                },
              ),
      );

      Map<String, dynamic> json = jsonDecode(response.body);
      if (response.statusCode == 200 && json.containsKey('heartbeat_s')) {
        return json['heartbeat_s'];
      } else {
        throw KVMApiError(error: "${response.statusCode}: ${response.body}");
      }
    } on KVMAuthError catch (_) {
      rethrow;
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
  }
}

class KVMApiError implements Exception {
  final String message;

  KVMApiError({String? error}) : message = error ?? "Something went wrong";

  @override
  String toString() {
    return message;
  }
}

class KVMAuthError implements Exception {
  final String message;

  KVMAuthError({String? error}) : message = error ?? "Session expired";

  @override
  String toString() {
    return message;
  }
}
