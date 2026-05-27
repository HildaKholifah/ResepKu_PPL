class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, String> toMap() => {
    "name": name,
    "email": email,
    "password": password,
    "password_confirmation": passwordConfirmation,
  };
}
