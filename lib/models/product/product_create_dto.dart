class ProductCreateDto {
  final String name;
  final String description;
  final double price;
  final int stock;
  final int companyId;

  ProductCreateDto({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.companyId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'companyId': companyId,
      };
}
