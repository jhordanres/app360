import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync360app/core/widgets/custom_confirmation_dialog.dart';
import 'package:sync360app/core/widgets/custom_search_bar.dart';
import 'package:sync360app/features/products/data/product_model.dart';
import '../../application/products_bloc.dart';
import '../../application/products_event.dart';
import '../../application/products_state.dart';
import 'create_product_page.dart';
import 'edit_product_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(FetchProducts());
  }

  void _filterProducts(String query, List<Product> products) {
    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredProducts = products
          .where((product) =>
              product.name.toLowerCase().contains(lowercaseQuery) ||
              product.price.toString().toLowerCase().contains(lowercaseQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: (value) {
                final currentState = context.read<ProductsBloc>().state;
                if (currentState is ProductsLoaded) {
                  _filterProducts(value, currentState.products);
                }
              },
              hintText: 'Search Products',
            ),
          ),
          actions: [
            IconButton(
  icon: const Icon(Icons.logout),
  onPressed: () {
    print('Mostrando diálogo de confirmación...');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        print('Construyendo diálogo...');
        return CustomConfirmationDialog(
          icon: Icons.logout,
          title: 'Cerrar Sesión',
          subtitle: '¿Estás seguro de que deseas cerrar sesión?',
          onCancel: () {
            print('Cancelar presionado');
            Navigator.pop(context);
          },
          onAccept: () async {
            print('Aceptar presionado');
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            Navigator.pushReplacementNamed(context, '/login');
          },
        );
      },
    );
  },
),



          ],

        ),
      ),
      body: BlocConsumer<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is ProductsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductsLoaded) {
            final productsToShow = _searchController.text.isEmpty
                ? state.products
                : _filteredProducts;
    
            return ListView.builder(
              itemCount: productsToShow.length,
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemBuilder: (context, index) {
                final product = productsToShow[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Price: \$${product.price}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<ProductsBloc>(),
                                    child: EditProductPage(product: product),
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => CustomConfirmationDialog(
                                  icon: Icons.delete,
                                  title: 'Eliminar Producto',
                                  subtitle: '¿Estás seguro de que deseas eliminar este producto?',
                                  onCancel: () => Navigator.pop(context),
                                  onAccept: () {
                                    context.read<ProductsBloc>().add(DeleteProduct(product.id));
                                    context.read<ProductsBloc>().add(FetchProducts());
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is ProductsError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }
          return const Center(child: Text('No products available.'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ProductsBloc>(),
                child: const CreateProductPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
