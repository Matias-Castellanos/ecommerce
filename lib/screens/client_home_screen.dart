import 'package:flutter/material.dart';
import '../models/product/product_dto.dart';
import '../models/user/user_info_dto.dart';
import '../services/api_service.dart';
import 'order_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  final UserInfoDto user;

  const ClientHomeScreen({super.key, required this.user});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final ApiService _api = ApiService();
  List<ProductDto> _products = [];
  List<ProductDto> _cart = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final products = await _api.getProducts();
      setState(() => _products = products);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addToCart(ProductDto product) {
    setState(() => _cart.add(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} añadido a tu orden')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda de Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderScreen(user: widget.user, cart: _cart),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(product.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text(
                        '${product.description}\nStock: ${product.stock} | Precio: \$${product.price.toStringAsFixed(2)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.add_shopping_cart,
                            color: Colors.green),
                        onPressed: () => _addToCart(product),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
