import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart'; // Import necesario para controlar la entrada de texto
import 'package:sync360app/core/widgets/custom_elevated_button.dart';
import 'package:sync360app/core/widgets/custom_text_field.dart'; // Importa tu widget CustomTextField
import '../../application/products_bloc.dart';
import '../../application/products_event.dart';
import '../../data/product_model.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({Key? key}) : super(key: key);

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void saveProduct() {
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

    final newProduct = Product(
      id: 0,
      name: name,
      price: price,
    );

    context.read<ProductsBloc>().add(AddProduct(newProduct));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
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
              text: 'Save Product',
              onPressed: saveProduct,
            ),
          ],
        ),
      ),
    );
  }
}
