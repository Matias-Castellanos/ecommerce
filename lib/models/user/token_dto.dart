class TokenDto {
  final String token;

  TokenDto({required this.token});

  factory TokenDto.fromJson(Map<String, dynamic> json) => TokenDto(
        token: json['token'],
      );

  Map<String, dynamic> toJson() => {
        'token': token,
      };
}
