import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user/token_dto.dart';
import '../models/user/user_info_dto.dart';
import '../models/user/user_login_dto.dart';
import '../models/user/user_register_dto.dart';
import '../models/product/product_dto.dart';
import '../models/product/product_create_dto.dart';
import '../models/order/order_dto.dart';
import '../models/order/order_create_dto.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String _baseUrl =
      'https://app-251027202854.azurewebsites.net/api'; // ✅ tu URL base correcta
  String? _token;
  UserInfoDto? _currentUser;

  // Headers dinámicos con el token si existe
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  UserInfoDto? get currentUser => _currentUser;

  void _setToken(String token) => _token = token;

  void clearToken() {
    _token = null;
    _currentUser = null;
  }

  // ---------------- AUTH ----------------

  Future<void> register(UserRegisterDto dto) async {
    final url = Uri.parse('$_baseUrl/Auth/register');
    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode >= 400) {
      throw Exception('Error al registrar usuario: ${res.body}');
    }
  }

  Future<void> testConnection() async {
    final url = Uri.parse('$_baseUrl/Auth/test');
    try {
      final res = await http.get(url);
      print('Respuesta: ${res.statusCode}');
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Future<UserInfoDto> login(UserLoginDto dto) async {
    final url = Uri.parse('$_baseUrl/Auth/login');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      // ✅ Guardamos token y usuario actual
      final tokenDto = TokenDto.fromJson(data);
      _setToken(tokenDto.token);

      // 🔁 Luego pedimos el perfil del usuario autenticado
      final profile = await getProfile(forceRefresh: true);
      return profile;
    } else {
      throw Exception('Error al iniciar sesión: ${res.statusCode} ${res.body}');
    }
  }

  // ---------------- USER ----------------

  Future<UserInfoDto> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _currentUser != null) return _currentUser!;

    final url = Uri.parse('$_baseUrl/Users');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode != 200) {
      throw Exception('No se pudo obtener el perfil');
    }

    _currentUser = UserInfoDto.fromJson(jsonDecode(res.body));
    return _currentUser!;
  }

  // ---------------- PRODUCTS ----------------

  Future<List<ProductDto>> getProducts() async {
    final url = Uri.parse('$_baseUrl/Products');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode != 200) {
      throw Exception('Error al obtener productos');
    }

    final List jsonList = jsonDecode(res.body);
    return jsonList.map((e) => ProductDto.fromJson(e)).toList();
  }

  Future<ProductDto> getProduct(int id) async {
    final url = Uri.parse('$_baseUrl/Products/$id');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode != 200) {
      throw Exception('Producto no encontrado');
    }

    return ProductDto.fromJson(jsonDecode(res.body));
  }

  /// Crea un producto (usado por empresas)
  Future<List<ProductDto>> getCompanyProducts(int companyId) async {
    final url = Uri.parse('$_baseUrl/companies/$companyId');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data is List) {
        return data.map((json) => ProductDto.fromJson(json)).toList();
      } else if (data is Map && data['products'] != null) {
        return (data['products'] as List)
            .map((json) => ProductDto.fromJson(json))
            .toList();
      } else {
        throw Exception('Formato de respuesta inesperado');
      }
    } else {
      throw Exception(
          'Error al obtener productos: ${res.statusCode} ${res.body}');
    }
  }

  /// ✅ Actualiza un producto existente (corregido)
  Future<void> updateProduct(ProductDto product) async {
    final url = Uri.parse('$_baseUrl/Products/${product.id}');
    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Error al actualizar producto: ${response.statusCode} ${response.body}');
    }
  }

  /// Elimina un producto
  Future<void> deleteProduct(int id) async {
    final url = Uri.parse('$_baseUrl/Products/$id');
    final res = await http.delete(url, headers: _headers);

    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('Error al eliminar producto: ${res.statusCode} ${res.body}');
    }
  }

  // ---------------- ORDERS ----------------

  Future<List<OrderDto>> getMyOrders() async {
    final url = Uri.parse('$_baseUrl/Orders');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode != 200) {
      throw Exception('Error al obtener pedidos');
    }

    final List jsonList = jsonDecode(res.body);
    return jsonList.map((e) => OrderDto.fromJson(e)).toList();
  }

  /// Crea una orden (el backend puede devolver 201 o 200)
  Future<void> createOrder(OrderCreateDto dto, List<int> productIds) async {
    final url = Uri.parse('$_baseUrl/Orders');

    final body = {
      'userId': dto.userId,
      'total': dto.total,
      'items': productIds
          .map((id) => {'productId': id, 'quantity': 1})
          .toList(),
    };

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Error al crear la orden: ${res.statusCode} ${res.body}');
    }
  }

  /// Crea un producto
  Future<void> createProduct(ProductCreateDto dto) async {
    final url = Uri.parse('$_baseUrl/Products');

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(dto.toJson()),
    );

    if (res.statusCode != 201 &&
        res.statusCode != 200 &&
        res.statusCode != 204) {
      throw Exception('Error al crear producto: ${res.statusCode} ${res.body}');
    }
  }
}
