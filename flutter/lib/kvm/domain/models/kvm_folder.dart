class KVMFolder {
  final int id;
  final String name;
  final Iterable<KVMFolder> subfolders;

  KVMFolder(this.id, this.name, this.subfolders);

  KVMFolder.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        subfolders = (json['subfolders'] as Iterable<dynamic>).map((json) {
          return KVMFolder.fromJson(json);
        });

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    return other is KVMFolder && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
