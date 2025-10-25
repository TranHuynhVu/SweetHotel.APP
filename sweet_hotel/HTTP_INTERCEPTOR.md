# HTTP Interceptor - Middleware cho Flutter

## 🎯 Tính năng

HTTP Interceptor hoạt động như middleware để:
- ✅ Tự động thêm Bearer token vào mọi request
- ✅ Kiểm tra token hết hạn trước khi gửi request
- ✅ Tự động refresh token khi sắp hết hạn (90% thời gian)
- ✅ Retry request với token mới nếu nhận 401 Unauthorized
- ✅ Queue các request trong lúc refresh token
- ✅ Tự động logout nếu refresh token thất bại

## 📋 Cách hoạt động

### Flow tự động:

```
1. User gọi API → ApiService.get('/User/Profile')
2. HttpInterceptor kiểm tra token
   ├─ Token còn hạn? → Gửi request với token hiện tại
   └─ Token sắp hết hạn (>90%)? 
       ├─ Gọi refresh token API
       ├─ Lưu access token mới
       └─ Gửi request với token mới
3. Nếu nhận 401:
   ├─ Auto refresh token
   ├─ Retry request với token mới
   └─ Nếu vẫn fail → Logout & redirect login
```

## 🔧 Cấu hình Backend API

Đảm bảo backend có endpoint refresh token:

**Endpoint:** `POST /api/Auth/RefreshToken`

**Request:**
```json
{
  "refresh_token": "091lnGR3Se+yzeilVFp..."
}
```

**Response:**
```json
{
  "token_type": "Bearer",
  "access_token": "eyJhbGciOiJI...",
  "expires_in": 3600,
  "refresh_token": "new_refresh_token",
  "scope": "Client"
}
```

## 💻 Sử dụng trong code

### 1. API calls tự động có interceptor:

```dart
// GET request
final userProfile = await ApiService().get('/User/Profile');
// → Tự động thêm token, tự động refresh nếu cần

// POST request
final result = await ApiService().post('/Bookings/Create', {
  'roomId': '123',
  'checkIn': '2025-10-25',
});
// → Token được handle tự động

// PUT request
await ApiService().put('/User/Update', userData);

// DELETE request
await ApiService().delete('/Bookings/Cancel/123');
```

### 2. Không cần quan tâm token:

```dart
class UserService {
  Future<User> getProfile() async {
    // Không cần lo về token, interceptor tự xử lý
    final data = await ApiService().get('/User/Profile');
    return User.fromJson(data);
  }
  
  Future<void> updateProfile(User user) async {
    // Token tự động refresh nếu hết hạn
    await ApiService().put('/User/Update', user.toJson());
  }
}
```

### 3. Check token manually (nếu cần):

```dart
final authService = AuthService();

// Check còn login không
bool isLoggedIn = await authService.isLoggedIn();

// Logout (xóa token)
await authService.logout();
// → Sau đó navigate to login screen
```

## 🔐 Token Management

### Token được lưu tự động:
- `access_token` - JWT token
- `refresh_token` - Để làm mới access token
- `token_type` - "Bearer"
- `expires_in` - Thời gian hết hạn (giây)
- `token_timestamp` - Thời điểm lưu token (để tính hết hạn)

### Auto refresh logic:
```dart
// Token hết hạn khi:
final elapsed = now - tokenTimestamp;
final isExpired = elapsed >= (expiresIn * 0.9);

// Refresh ở 90% thời gian để an toàn
// VD: Token 3600s → refresh sau 3240s (54 phút)
```

## ⚙️ Cấu hình

### Điều chỉnh thời gian refresh:

```dart
// Trong http_interceptor.dart
Future<bool> _isTokenExpired() async {
  // ...
  // Đổi 0.9 thành giá trị khác:
  // - 0.8 = refresh ở 80% thời gian (sớm hơn)
  // - 0.95 = refresh ở 95% thời gian (muộn hơn)
  return elapsed >= (expiresIn * 0.9);
}
```

### Điều chỉnh số lần retry:

```dart
// Trong http_interceptor.dart
Future<http.Response> request({
  // ...
  int maxRetries = 1, // Đổi thành 2, 3 nếu muốn retry nhiều hơn
}) async {
  // ...
}
```

## 🚨 Error Handling

### Khi refresh token fail:

```dart
try {
  final data = await ApiService().get('/User/Profile');
} catch (e) {
  if (e.toString().contains('Unauthorized')) {
    // Token hết hạn và refresh fail
    // → Redirect to login
    Navigator.pushReplacementNamed(context, '/login');
  }
}
```

### Global error handler (khuyên dùng):

```dart
// Trong main.dart hoặc base widget
void handleApiError(dynamic error) {
  if (error.toString().contains('Unauthorized')) {
    // Auto logout và redirect
    AuthService().logout();
    // Navigate to login
  } else {
    // Show error message
    print('API Error: $error');
  }
}
```

## 🔄 Queue System

Interceptor có queue system để tránh multiple refresh cùng lúc:

```
Request 1 → Check token → Refreshing...
Request 2 → Check token → Added to queue
Request 3 → Check token → Added to queue

Token refreshed!
→ Complete all queued requests with new token
```

## 📝 Notes

1. **Login/Register không cần interceptor** vì chưa có token
2. **Refresh token API** không được đi qua interceptor (tránh infinite loop)
3. **Token timestamp** được lưu khi login hoặc refresh
4. **Logout** xóa tất cả token và timestamp

## 🧪 Testing

```dart
// Test token refresh
void testTokenRefresh() async {
  // 1. Login
  await AuthService().login(LoginRequest(...));
  
  // 2. Đợi token hết hạn (hoặc set timestamp cũ)
  await Future.delayed(Duration(seconds: 3700));
  
  // 3. Gọi API → Sẽ tự động refresh
  final profile = await ApiService().get('/User/Profile');
  print('Profile loaded with refreshed token!');
}
```

## ⚡ Performance

- **Singleton pattern**: Chỉ 1 instance của HttpInterceptor
- **Queue system**: Tránh multiple refresh calls
- **Cache token**: Không đọc SharedPreferences mỗi request
- **Smart refresh**: Chỉ refresh khi cần (90% thời gian)

## 🎓 So sánh với middleware khác

| Feature | HttpInterceptor | Dio Interceptor | HTTP Client |
|---------|----------------|-----------------|-------------|
| Auto refresh token | ✅ | ✅ | ❌ |
| Queue system | ✅ | ✅ | ❌ |
| Retry on 401 | ✅ | ✅ | ❌ |
| Built-in | ✅ | ❌ (Need package) | ❌ |
| Learning curve | Easy | Medium | Hard |

## 🔗 Alternative: Sử dụng Dio package

Nếu muốn dùng thư viện mạnh hơn:

```yaml
# pubspec.yaml
dependencies:
  dio: ^5.4.0
```

```dart
// Dio với interceptor
final dio = Dio();
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) async {
    // Add token to header
    final token = await getToken();
    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  },
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Refresh token and retry
      await refreshToken();
      return handler.resolve(await retry(error.requestOptions));
    }
    return handler.next(error);
  },
));
```

Nhưng với HttpInterceptor custom này, bạn có toàn quyền kiểm soát! 🚀
