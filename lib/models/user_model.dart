class User {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  User({required this.id, required this.name, required this.email, this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],

      avatarUrl: json['avatar_url'], 
    );
  }
}