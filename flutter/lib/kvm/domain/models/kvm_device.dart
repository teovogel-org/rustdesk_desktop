class KVMDevice {
  final int id;
  final String name;
  final String? id_rust;
  final String? pass_rust;
  final String serialno;
  final int folder_id;

  KVMDevice.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        id_rust = json['id_rust'] as String?,
        pass_rust = json['pass_rust'] as String?,
        serialno = json['serial_number'] as String,
        folder_id = json['folder_id'] as int;

  @override
  String toString() {
    return name;
  }
}
