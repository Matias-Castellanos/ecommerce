class UserInfoDto {
  final int id;
  final String email;
  final int role;
  final int? companyId;
  final String? token; // ✅ <-- agrega esta línea

  UserInfoDto({
    required this.id,
    required this.email,
    required this.role,
    this.companyId,
    this.token, // ✅
  });

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInfoDto(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      companyId: json['companyId'],
      token: json['token'], // ✅ asegúrate de leerlo si viene del backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'companyId': companyId,
      'token': token, // ✅
    };
  }
}
