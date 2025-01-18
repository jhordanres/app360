import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Dio dio;

  AuthBloc({required this.dio}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
  emit(AuthLoading());

  try {
    final response = await dio.post(
      '/web/session/authenticate',
      data: {
        "params": {
          "login": event.email,
          "password": event.password,
          "db": "test"
        }
      },
    );

    print("Login response: ${response.data}");

    final data = response.data;

    if (data['result'] != null) {
  final sessionId = response.headers['set-cookie']
      ?.firstWhere((header) => header.contains('session_id'))
      ?.split(';')
      ?.firstWhere((item) => item.contains('session_id'))
      ?.split('=')[1];

  if (sessionId != null && sessionId.isNotEmpty) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', sessionId);

    emit(AuthAuthenticated());
  } else {
    emit(AuthError("Session ID not found in response headers."));
  }
} else {
  emit(AuthError("Invalid email or password."));
}

  } catch (e) {
    if (e is DioError) {
      print("Dio error: ${e.message}");
      print("Response data: ${e.response?.data}");
    }
    emit(AuthError("Failed to connect to the server."));
  }
}

}
