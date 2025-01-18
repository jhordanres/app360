class LoginResponse {
  final String sessionId;
  final String name;

  LoginResponse({required this.sessionId, required this.name});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      sessionId: json['session_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'name': name,
    };
  }
}
