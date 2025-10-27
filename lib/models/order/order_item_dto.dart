class OrderItemDto {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItemDto({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) => OrderItemDto(
        productId: json['productId'],
        productName: json['productName'],
        quantity: json['quantity'],
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}
