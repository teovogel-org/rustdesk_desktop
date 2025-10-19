class KVMTenant {
  final int id;
  final String name;

  KVMTenant(this.id, this.name);

  KVMTenant.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String;

  @override
  String toString() {
    return "$name ($id)";
  }

  @override
  bool operator ==(Object other) {
    return other is KVMTenant && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
