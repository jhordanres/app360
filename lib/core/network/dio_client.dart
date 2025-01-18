import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  static late Dio dio;

  static Future<void> initialize() async {
    dio = Dio(BaseOptions(
      baseUrl: 'http://34.176.59.20:8069',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        options.headers['Cookie'] = token;
      }
      print(
          "Request: ${options.method} ${options.path}, data: ${options.data}");
      handler.next(options);
    }, onError: (DioError e, handler) {
      return handler.next(e);
    }));
  }
}
