class User {
  final String firstName;
  final String lastName;
  final String email;
  final String specialty;
  final String? avatarUrl;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.specialty,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      specialty: json['specialty'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "specialty": specialty,
      "avatar_url": avatarUrl,
    };
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? specialty,
    String? avatarUrl,
  }) {
    return User(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      specialty: specialty ?? this.specialty,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
