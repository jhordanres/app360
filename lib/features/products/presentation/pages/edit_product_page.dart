import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart'; // Para los inputFormatters
import 'package:sync360app/core/widgets/custom_elevated_button.dart';
import 'package:sync360app/core/widgets/custom_text_field.dart'; // Importa el CustomTextField
import '../../application/products_bloc.dart';
import '../../application/products_event.dart';
import '../../data/product_model.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    priceController = TextEditingController(text: widget.product.price.toString());
  }

  void updateProduct() {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();

    if (name.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    final updatedProduct = Product(
      id: widget.product.id,
      name: name,
      price: price,
    );

    context.read<ProductsBloc>().add(UpdateProduct(updatedProduct));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(
              controller: nameController,
              labelText: 'Product Name',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: priceController,
              labelText: 'Price',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),
            CustomElevatedButton(
              text: 'Update Product',
              onPressed: updateProduct,
            ),
          ],
        ),
      ),
    );
  }
}
