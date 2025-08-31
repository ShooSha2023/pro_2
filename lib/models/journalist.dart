class Journalist {
  final String firstName;
  final String lastName;
  final String email;
  final String specialty;
  final String password;
  final String password2;

  Journalist({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.specialty,
    required this.password,
    required this.password2,
  });

  // تحويل Dart object → JSON
  Map<String, dynamic> toJson() {
    return {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "specialty": specialty,
      "password": password,
      "password2": password2,
    };
  }

  // تحويل JSON → Dart object
  factory Journalist.fromJson(Map<String, dynamic> json) {
    return Journalist(
      firstName: json["first_name"] ?? "",
      lastName: json["last_name"] ?? "",
      email: json["email"] ?? "",
      specialty: json["specialty"] ?? "",
      password: json["password"] ?? "",
      password2: json["password2"] ?? "",
    );
  }

  get specialization => null;
}
