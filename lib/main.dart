import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync360app/features/auth/application/auth_bloc.dart';
import 'package:sync360app/features/auth/presentation/pages/login_page.dart';
import 'package:sync360app/features/products/application/products_bloc.dart';
import 'package:sync360app/features/products/data/product_repository_imp.dart';
import 'package:sync360app/features/products/presentation/pages/products_page.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://34.176.59.20:8069',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  runApp(MyApp(dio: dio));
}

class MyApp extends StatelessWidget {
  final Dio dio;

  const MyApp({Key? key, required this.dio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: dio),
        RepositoryProvider(
          create: (_) => ProductRepositoryImpl(dio: dio),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthBloc(dio: dio)),
          BlocProvider(
            create: (context) =>
                ProductsBloc(repository: context.read<ProductRepositoryImpl>()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CRUD 360 App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => LoginPage(),
            '/products': (context) => ProductsPage(),
          },
        ),
      ),
    );
  }
}
