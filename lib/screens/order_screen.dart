import 'package:flutter/material.dart';
import '../models/product/product_dto.dart';
import '../models/user/user_info_dto.dart';
import '../models/order/order_create_dto.dart';
import '../services/api_service.dart';

class OrderScreen extends StatefulWidget {
  final UserInfoDto user;
  final List<ProductDto> cart;

  const OrderScreen({super.key, required this.user, required this.cart});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final ApiService _api = ApiService();
  bool _isSubmitting = false;

  double get _total =>
      widget.cart.fold(0, (sum, item) => sum + item.price);

  Future<void> _submitOrder() async {
    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu carrito está vacío')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final orderDto = OrderCreateDto(
        userId: widget.user.id, // ✅ Usuario que hace el pedido
        productIds: widget.cart.map((p) => p.id).toList(), // ✅ IDs de productos
        total: _total, // ✅ Total calculado
      );

      await _api.createOrder(orderDto, widget.cart.map((p) => p.id).toList());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orden creada exitosamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear orden: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Orden'),
      ),
      body: widget.cart.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final product = widget.cart[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle:
                            Text('Precio: \$${product.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              widget.cart.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Total: \$${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitOrder,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: const Text('Confirmar Orden'),
                            ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}