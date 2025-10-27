import 'order_item_dto.dart';

class OrderDto {
  final int id;
  final DateTime orderDate;
  final double total;
  final List<OrderItemDto> items;

  OrderDto({
    required this.id,
    required this.orderDate,
    required this.total,
    required this.items,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) => OrderDto(
        id: json['id'],
        orderDate: DateTime.parse(json['orderDate']),
        total: (json['total'] as num).toDouble(),
        items: (json['items'] as List)
            .map((i) => OrderItemDto.fromJson(i))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderDate': orderDate.toIso8601String(),
        'total': total,
        'items': items.map((e) => e.toJson()).toList(),
      };
}
