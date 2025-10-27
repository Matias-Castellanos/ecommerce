import 'package:flutter/material.dart';
import '../models/order/order_dto.dart';
import '../models/user/user_info_dto.dart';
import '../services/api_service.dart';

class UserOrdersScreen extends StatefulWidget {
  final UserInfoDto user;

  const UserOrdersScreen({super.key, required this.user});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  final ApiService _api = ApiService();
  List<OrderDto> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final orders = await _api.getMyOrders();
      setState(() => _orders = orders);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar pedidos: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    // Formato simple YYYY-MM-DD
    return '${dt.year.toString().padLeft(4, '0')}-'
           '${dt.month.toString().padLeft(2, '0')}-'
           '${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(
                  child: Text(
                    'No tienes pedidos aún.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchOrders,
                  child: ListView.builder(
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];

                      // order.orderDate es DateTime según tu DTO
                      final dateStr = _formatDate(order.orderDate);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.receipt_long,
                              color: Colors.blue),
                          title: Text('Pedido #${order.id}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total: \$${order.total.toStringAsFixed(2)}'),
                              Text('Fecha: $dateStr'),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navegar a detalle de pedido si lo implementas
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
