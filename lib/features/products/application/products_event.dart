import 'package:equatable/equatable.dart';
import '../data/product_model.dart';

abstract class ProductsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProducts extends ProductsEvent {}

class AddProduct extends ProductsEvent {
  final Product product;

  AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductsEvent {
  final Product product;

  UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductsEvent {
  final int productId;

  DeleteProduct(this.productId);

  @override
  List<Object?> get props => [productId];
}
