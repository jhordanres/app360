import 'product_model.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int productId);
}
