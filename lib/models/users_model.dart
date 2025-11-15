class User {
  final int? id;
  final String email;
  final String username;
  final String password;
  final String? foto;


  User({
    this.id,
    required this.email,
    required this.username,
    required this.password,
    this.foto,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      foto: map['foto'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'password': password,
      'foto': foto,
    };
  }

 
  User copyWith({
    int? id,
    String? email,
    String? username,
    String? password,
    String? foto,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      foto: foto ?? this.foto,
    );
  }


  @override
  String toString() {
    return 'User{id: $id, email: $email, username: $username, foto: $foto}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.username == username;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        username.hashCode ^
        password.hashCode;
  }
}