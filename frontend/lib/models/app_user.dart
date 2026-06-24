/// The signed-in patient.
class AppUser {
  final String username;
  final String phone;

  const AppUser({required this.username, required this.phone});

  Map<String, dynamic> toJson() => {'username': username, 'phone': phone};

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        username: json['username'] as String,
        phone: json['phone'] as String,
      );
}
