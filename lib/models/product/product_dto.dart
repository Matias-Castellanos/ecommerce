class ProductDto {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int companyId;

  ProductDto({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.companyId,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) => ProductDto(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        stock: json['stock'],
        companyId: json['companyId'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'companyId': companyId,
      };
}
