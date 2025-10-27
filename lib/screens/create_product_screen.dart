import 'package:flutter/material.dart';
import '../models/product/product_create_dto.dart';
import '../models/user/user_info_dto.dart';
import '../services/api_service.dart';

class CreateProductScreen extends StatefulWidget {
  final UserInfoDto user; // 👈 se recibe el usuario logueado

  const CreateProductScreen({super.key, required this.user});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  bool _isSubmitting = false;

  Future<void> _createProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 🧠 Imprime los datos del usuario para depurar
      print('Usuario actual: ${widget.user.toJson()}');

      // ✅ Usa el id del usuario si companyId es nulo
      final companyId = widget.user.companyId ?? widget.user.id;

      // ignore: dead_code
      if (companyId == null) {
        throw Exception('El usuario no tiene un companyId ni un id válido');
      }

      final dto = ProductCreateDto(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        companyId: companyId,
      );

      await _api.createProduct(dto);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto creado exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear producto: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese una descripción'
                    : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Ingrese un precio válido'
                        : null,
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null
                        ? 'Ingrese una cantidad válida'
                        : null,
              ),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createProduct,
                      child: const Text('Guardar Producto'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
