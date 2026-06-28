/// The signed-in patient (from the backend `Patient.toJSON()`).
class AppUser {
  final String id;
  final String username;
  final String phone;
  final String avatarUrl;

  const AppUser({
    this.id = '',
    required this.username,
    required this.phone,
    this.avatarUrl = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'phone': phone,
        'avatarUrl': avatarUrl,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['id'] ?? json['_id'] ?? '') as String,
        username: (json['username'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
        avatarUrl: (json['avatarUrl'] ?? '') as String,
      );
}
