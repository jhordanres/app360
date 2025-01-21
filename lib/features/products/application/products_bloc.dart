import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/product_repository.dart';
import 'products_event.dart';
import 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductRepository repository;

  ProductsBloc({required this.repository}) : super(ProductsInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }

  Future<void> _onFetchProducts(FetchProducts event, Emitter<ProductsState> emit) async {
    emit(ProductsLoading());
    try {
      final products = await repository.fetchProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError('Failed to fetch products: $e'));
    }
  }

  Future<void> _onAddProduct(AddProduct event, Emitter<ProductsState> emit) async {
    try {
      await repository.addProduct(event.product);
      add(FetchProducts()); // Recargar lista de productos
    } catch (e) {
      emit(ProductsError('Failed to add product: $e'));
    }
  }

  Future<void> _onUpdateProduct(UpdateProduct event, Emitter<ProductsState> emit) async {
    try {
      emit(ProductsLoading());
      await repository.updateProduct(event.product);
      add(FetchProducts()); // Recargar lista de productos después de actualizar
    } catch (e) {
      emit(ProductsError('Failed to update product: $e'));
    }
  }

  Future<void> _onDeleteProduct(DeleteProduct event, Emitter<ProductsState> emit) async {
    try {
      emit(ProductsLoading());
      await repository.deleteProduct(event.productId);
      add(FetchProducts()); // Recargar lista de productos después de eliminar
    } catch (e) {
      emit(ProductsError('Failed to delete product: $e'));
    }
  }
}
