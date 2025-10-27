class OrderCreateDto {
  final int userId;
  final List<int> productIds;
  final double total;

  OrderCreateDto({
    required this.userId,
    required this.productIds,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'productIds': productIds,
        'total': total,
      };
}
