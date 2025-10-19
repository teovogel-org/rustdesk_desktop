class KVMSession {
  final String authToken;
  final String refreshToken;

  KVMSession.fromJson(Map<String, dynamic> json)
      : authToken = json['access_token'] as String,
        refreshToken = json['refresh_token'] as String;
}
