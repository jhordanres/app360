import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_model.dart';
import 'product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final Dio dio;

  ProductRepositoryImpl({required this.dio});

  @override
  Future<List<Product>> fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found. Please log in again.');
      }

      final response = await dio.post(
        '/web/dataset/call_kw',
        options: Options(headers: {
          'Cookie': 'session_id=$token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
        data: {
          "params": {
            "model": "product.template",
            "method": "search_read",
            "args": [],
            "kwargs": {
              "domain": [["active", "=", true]],
              "fields": [
                "id",
                "name",
                "default_code",
                "list_price",
                "standard_price",
                "categ_id"
              ],
            }
          }
        },
      );

      if (response.data != null && response.data['result'] != null) {
        final data = response.data['result'] as List<dynamic>;
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception("The 'result' field is missing or null in the response.");
      }
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<void> addProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found. Please log in again.');
      }

      await dio.post(
        '/web/dataset/call_kw',
        options: Options(headers: {
          'Cookie': 'session_id=$token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
        data: {
          "params": {
            "model": "product.template",
            "method": "create",
            "args": [
              {
                "name": product.name,
                "list_price": product.price,
                "default_code": "NEW-CODE-${DateTime.now().millisecondsSinceEpoch}",
                "categ_id": 1
              }
            ],
            "kwargs": {}
          }
        },
      );
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  @override
  Future<void> updateProduct(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found. Please log in again.');
      }

      final response = await dio.post(
        '/web/dataset/call_kw',
        options: Options(headers: {
          'Cookie': 'session_id=$token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
        data: {
          "params": {
            "model": "product.template",
            "method": "write",
            "args": [
              [product.id],
              {
                "name": product.name,
                "list_price": product.price,
                "default_code": "UPDATED-CODE-${product.id}",
              }
            ],
            "kwargs": {},
          }
        },
      );

      // Validar la respuesta de la API
      if (response.data == null || response.data['result'] != true) {
        throw Exception("Failed to update the product on the server.");
      }
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }


    @override
  Future<void> deleteProduct(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token not found. Please log in again.');
      }

      final response = await dio.post(
        '/web/dataset/call_kw',
        options: Options(headers: {
          'Cookie': 'session_id=$token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
        data: {
          "params": {
            "model": "product.template",
            "method": "unlink",
            "args": [
              [productId]
            ],
            "kwargs": {},
          }
        },
      );

      
      if (response.data == null || response.data['result'] != true) {
        throw Exception("Failed to delete the product on the server.");
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

}
