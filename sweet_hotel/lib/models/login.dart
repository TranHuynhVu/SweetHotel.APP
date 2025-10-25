class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email.trim().toLowerCase(),
    'password': password,
  };
}

class LoginResponse {
  final String tokenType;
  final String accessToken;
  final int expiresIn;
  final String refreshToken;
  final String scope;

  LoginResponse({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
    required this.scope,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    tokenType: json['token_type'] ?? 'Bearer',
    accessToken: json['access_token'] ?? '',
    expiresIn: json['expires_in'] ?? 3600,
    refreshToken: json['refresh_token'] ?? '',
    scope: json['scope'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'token_type': tokenType,
    'access_token': accessToken,
    'expires_in': expiresIn,
    'refresh_token': refreshToken,
    'scope': scope,
  };
}
