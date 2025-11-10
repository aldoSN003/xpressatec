class CustomPictogram {
  CustomPictogram({
    required this.id,
    required this.name,
    required this.relativePath,
    required this.parentPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String relativePath;
  final String parentPath;
  final DateTime createdAt;

  CustomPictogram copyWith({
    String? id,
    String? name,
    String? relativePath,
    String? parentPath,
    DateTime? createdAt,
  }) {
    return CustomPictogram(
      id: id ?? this.id,
      name: name ?? this.name,
      relativePath: relativePath ?? this.relativePath,
      parentPath: parentPath ?? this.parentPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relativePath': relativePath,
      'parentPath': parentPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomPictogram.fromMap(Map<String, dynamic> map) {
    final createdAtString = map['createdAt'] as String?;
    final parsedCreatedAt = createdAtString != null
        ? DateTime.tryParse(createdAtString)
        : null;

    return CustomPictogram(
      id: map['id'] as String,
      name: map['name'] as String,
      relativePath: map['relativePath'] as String,
      parentPath: map['parentPath'] as String,
      createdAt: parsedCreatedAt,
    );
  }
}
