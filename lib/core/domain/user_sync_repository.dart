class UserSnapshot {
  const UserSnapshot({
    required this.group,
    required this.favorites,
    required this.updatedAt,
  });
  final String group;
  final Set<String> favorites;
  final DateTime updatedAt;
  Map<String, Object> toJson() => {
    'group': group,
    'favorites': favorites.toList(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };
  factory UserSnapshot.fromJson(Map<String, Object?> json) => UserSnapshot(
    group: json['group'] as String,
    favorites: (json['favorites'] as List).cast<String>().toSet(),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

abstract interface class UserSyncRepository {
  Future<UserSnapshot?> read(String uid);
  Future<UserSnapshot> saveIfNewer(String uid, UserSnapshot snapshot);
}
