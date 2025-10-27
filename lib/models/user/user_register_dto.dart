class UserRegisterDto {
  final String email;
  final String password;
  final int role; // 0 = Admin, 1 = Company, 2 = Customer

  UserRegisterDto({
    required this.email,
    required this.password,
  }) : role = 2; // ✅ Fijamos el rol por defecto como Customer

  factory UserRegisterDto.fromJson(Map<String, dynamic> json) => UserRegisterDto(
        email: json['email'],
        password: json['password'],
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'role': role,
      };
}
