class UserLoginDto {
  final String email;
  final String password;

  UserLoginDto({
    required this.email,
    required this.password,
  });

  factory UserLoginDto.fromJson(Map<String, dynamic> json) => UserLoginDto(
        email: json['email'],
        password: json['password'],
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
