import 'package:flutter/material.dart';
import '../models/product/product_dto.dart';
import '../models/user/user_info_dto.dart';
import '../services/api_service.dart';
import 'create_product_screen.dart';
import 'edit_product_screen.dart';

class CompanyHomeScreen extends StatefulWidget {
  final UserInfoDto user;

  const CompanyHomeScreen({super.key, required this.user});

  @override
  State<CompanyHomeScreen> createState() => _CompanyHomeScreenState();
}

class _CompanyHomeScreenState extends State<CompanyHomeScreen> {
  final ApiService _api = ApiService();
  List<ProductDto> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    debugPrint('--- Empresa logueada en CompanyHomeScreen ---');
    debugPrint('UserID: ${widget.user.id}');
    debugPrint('Role: ${widget.user.role}');
    debugPrint('CompanyID: ${widget.user.companyId}');
    debugPrint('---------------------------------------------');

    _fetchProducts();
  }


  Future<void> _fetchProducts() async {
    try {
      final products = await _api.getProducts(); // ✅ ahora trae todos
      setState(() {
        _products = products;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar productos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateProductScreen(user: widget.user),
      ),
    );
    _fetchProducts(); // 🔄 refresca lista al volver
  }

  Future<void> _editProduct(ProductDto product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(product: product, user: widget.user),
      ),
    );
    _fetchProducts(); // 🔄 refresca lista al volver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos (Empresa)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              child: _products.isEmpty
                  ? const Center(child: Text('No hay productos disponibles.'))
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final belongsToCompany =
                            product.companyId == widget.user.companyId;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              '${product.description}\nStock: ${product.stock} | Precio: \$${product.price.toStringAsFixed(2)}',
                            ),
                            isThreeLine: true,
                            trailing: belongsToCompany
                                ? IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _editProduct(product),
                                  )
                                : null, // 🔒 solo la empresa que creó puede editar
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProduct,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Producto'),
      ),
    );
  }
}
