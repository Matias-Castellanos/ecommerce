class UserInfoDto {
  final int id;
  final String email;
  final int role; // 0 = Cliente, 1 = Empresa
  final int? companyId; // <- Solo se usa si el usuario es empresa

  UserInfoDto({
    required this.id,
    required this.email,
    required this.role,
    this.companyId,
  });

  factory UserInfoDto.fromJson(Map<String, dynamic> json) => UserInfoDto(
        id: json['id'],
        email: json['email'],
        role: json['role'],
        companyId: json['companyId'], // puede ser null si es cliente
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        if (companyId != null) 'companyId': companyId,
      };
}
