# 🏨 Sweet Hotel

Ứng dụng di động đặt phòng khách sạn hiện đại được xây dựng bằng Flutter, tích hợp xác thực người dùng, duyệt phòng và quản lý đặt phòng.

## 📱 Giới Thiệu

Sweet Hotel là ứng dụng quản lý khách sạn toàn diện cho phép người dùng:
- Duyệt các phòng khách sạn theo danh mục
- Xem thông tin chi tiết phòng với hình ảnh và tiện nghi
- Kiểm tra tình trạng phòng theo khoảng thời gian
- Tạo và quản lý đặt phòng
- Xác thực người dùng bảo mật với JWT tokens

## ✨ Tính Năng

### 🔐 Xác Thực
- Đăng ký người dùng với xác thực email
- Đăng nhập bảo mật với JWT token
- Cơ chế tự động làm mới token
- Session đăng nhập lưu trữ lâu dài

### 🏨 Quản Lý Phòng
- Duyệt phòng theo danh mục
- Xem thông tin chi tiết phòng
- Hình ảnh phòng chất lượng cao
- Kiểm tra tình trạng phòng trống theo thời gian thực
- Lọc phòng theo khoảng ngày

### 📅 Hệ Thống Đặt Phòng
- Tạo đặt phòng mới với chọn ngày
- Xem lịch sử đặt phòng
- Theo dõi trạng thái đặt phòng
- Hủy đặt phòng
- Tính giá dựa trên số ngày

### 🎨 Giao Diện
- Material Design 3
- Bố cục responsive
- Widgets tùy chỉnh nhất quán
- Điều hướng mượt mà
- Xử lý trạng thái loading và lỗi

## 🏗️ Kiến Trúc

Dự án tuân theo nguyên tắc **Clean Architecture** với phân tách rõ ràng các layer:

```
lib/
├── main.dart                 # Điểm khởi đầu ứng dụng
├── constants/                # Hằng số toàn ứng dụng
│   ├── api_endpoints.dart   # Địa chỉ API URLs
│   ├── app_colors.dart      # Màu sắc theme
│   └── app_texts.dart       # Văn bản tĩnh
├── models/                   # Models dữ liệu (DTOs)
│   ├── booking.dart         # Model đặt phòng
│   ├── category.dart        # Model danh mục
│   ├── login.dart           # Model đăng nhập
│   ├── register.dart        # Model đăng ký
│   └── room.dart            # Model phòng
├── routes/                   # Quản lý điều hướng
│   └── app_routes.dart      # Định nghĩa routes
├── screens/                  # Màn hình giao diện
│   ├── booking_screen.dart           # Màn hình danh sách đặt phòng
│   ├── create_booking_screen.dart    # Màn hình tạo đặt phòng
│   ├── home_screen.dart              # Màn hình trang chủ
│   ├── login_screen.dart             # Màn hình đăng nhập
│   ├── register_screen.dart          # Màn hình đăng ký
│   ├── room_detail_screen.dart       # Màn hình chi tiết phòng
│   └── rooms_screen.dart             # Màn hình danh sách phòng
├── services/                 # Lớp logic nghiệp vụ
│   ├── api_service.dart          # Wrapper HTTP client
│   ├── auth_service.dart         # Logic xác thực
│   ├── booking_service.dart      # Xử lý đặt phòng
│   ├── category_service.dart     # Xử lý danh mục
│   ├── http_interceptor.dart     # Tự động làm mới token
│   ├── local_storage.dart        # Lưu trữ cục bộ
│   └── room_service.dart         # Xử lý phòng
├── utils/                    # Hàm tiện ích
│   ├── format_date.dart      # Format ngày tháng
│   └── jwt_helper.dart       # Xử lý JWT
└── widgets/                  # Components UI tái sử dụng
    ├── custom_bottom_nav.dart    # Thanh điều hướng dưới
    ├── custom_button.dart        # Button tùy chỉnh
    └── custom_textfield.dart     # Ô nhập liệu tùy chỉnh
```

## 🔄 Luồng Hoạt Động

### Luồng Xác Thực
```
Khởi động App → Kiểm tra Token → Màn hình Login/Home
Login → Gọi API → Lưu Token → Màn hình Home
Request API → Thêm Token → Tự động Refresh nếu hết hạn
```

### Luồng Đặt Phòng
```
Home → Danh mục → Danh sách Phòng → Chi tiết Phòng → Tạo Đặt Phòng → Xác nhận
```

## 🛠️ Công Nghệ Sử Dụng

- **Framework:** Flutter 3.9.2
- **Ngôn ngữ:** Dart
- **Quản lý State:** StatefulWidget
- **HTTP Client:** http ^1.5.0
- **Lưu trữ cục bộ:** shared_preferences ^2.5.3
- **Format ngày:** intl ^0.20.2
- **API:** REST API với JWT Authentication

## 📦 Dependencies (Thư Viện)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.5.0              # Gọi HTTP requests
  shared_preferences: ^2.5.3 # Lưu trữ cục bộ
  intl: ^0.20.2             # Format ngày tháng

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0     # Kiểm tra code
```

## 🚀 Hướng Dẫn Bắt Đầu

### Yêu Cầu Hệ Thống

- Flutter SDK (>= 3.9.2)
- Dart SDK (>= 3.9.2)
- Android Studio / VS Code
- Android Emulator hoặc iOS Simulator

### Cài Đặt

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd sweet_hotel
   ```

2. **Cài đặt dependencies**
   ```bash
   flutter pub get
   ```

3. **Cấu hình API endpoint**
   
   Chỉnh sửa file `lib/constants/api_endpoints.dart`:
   ```dart
   // Production (Sản xuất)
   static const String baseUrl = 'https://api.sweethotel.kodopo.tech/api';
   
   // Development - Android Emulator (Phát triển)
   // static const String baseUrl = 'http://10.0.2.2:5000/api';
   
   // Development - iOS Simulator / Thiết bị thật
   // static const String baseUrl = 'http://192.168.1.xxx:5000/api';
   ```

4. **Chạy ứng dụng**
   ```bash
   # Kiểm tra các thiết bị có sẵn
   flutter devices
   
   # Chạy trên thiết bị cụ thể
   flutter run -d <device-id>
   
   # Chạy ở chế độ debug
   flutter run
   
   # Chạy ở chế độ release
   flutter run --release
   ```

### Build Cho Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🔑 Chi Tiết Triển Khai Tính Năng

### Tự Động Làm Mới Token
Ứng dụng sử dụng `HttpInterceptor` để tự động làm mới access token khi hết hạn:
```dart
// Chặn tất cả HTTP requests
// Tự động thêm Bearer token vào headers
// Phát hiện response 401 (Unauthorized)
// Tự động refresh token
// Thử lại request ban đầu
```

### Xác Thực Lâu Dài
Session người dùng được duy trì bằng `SharedPreferences`:
```dart
// Lưu access_token và refresh_token
// Kiểm tra tính hợp lệ của token khi khởi động
// Tự động chuyển đến màn hình phù hợp
```

### Validation Form
Tất cả form nhập liệu đều có validation toàn diện:
- Kiểm tra định dạng email
- Yêu cầu độ mạnh mật khẩu
- Kiểm tra trường bắt buộc
- Validation khoảng ngày

## 📱 Tổng Quan Các Màn Hình

| Màn hình | Mô tả |
|----------|-------|
| **Login** | Đăng nhập với email/password |
| **Register** | Đăng ký tài khoản mới |
| **Home** | Hiển thị danh mục và điều hướng |
| **Rooms** | Danh sách phòng có sẵn |
| **Room Detail** | Thông tin chi tiết phòng và đặt phòng |
| **Bookings** | Lịch sử đặt phòng của người dùng |
| **Create Booking** | Chọn ngày và tạo đặt phòng |

## 🔒 Tính Năng Bảo Mật

- ✅ Xác thực dựa trên JWT token
- ✅ Lưu trữ token bảo mật
- ✅ Cơ chế tự động làm mới token
- ✅ Mã hóa mật khẩu (xử lý bởi backend)
- ✅ Xác thực SSL certificate (có thể cấu hình)
- ✅ Xử lý timeout request
- ✅ Triển khai error boundary

## 🧪 Testing (Kiểm Thử)

```bash
# Chạy tất cả tests
flutter test

# Chạy tests với coverage
flutter test --coverage

# Chạy file test cụ thể
flutter test test/widget_test.dart
```

## 📝 API Endpoints

Ứng dụng kết nối đến các API endpoints sau:

**Xác thực (Authentication):**
- `POST /api/Auth/Login` - Đăng nhập
- `POST /api/Auth/Register` - Đăng ký
- `POST /api/Auth/RefreshToken` - Làm mới token
- `POST /api/Auth/Logout` - Đăng xuất

**Danh mục (Categories):**
- `GET /api/Categories` - Lấy tất cả danh mục
- `GET /api/Categories/{id}` - Lấy danh mục theo ID

**Phòng (Rooms):**
- `GET /api/Rooms` - Lấy tất cả phòng
- `GET /api/Rooms/{id}` - Lấy phòng theo ID
- `POST /api/Rooms/AvailableByDateRange` - Kiểm tra phòng trống

**Đặt phòng (Bookings):**
- `GET /api/Bookings` - Lấy danh sách đặt phòng
- `POST /api/Bookings` - Tạo đặt phòng mới
- `PUT /api/Bookings/{id}` - Cập nhật đặt phòng
- `DELETE /api/Bookings/{id}` - Hủy đặt phòng

## 🐛 Debug và Xử Lý Lỗi

### Lỗi Thường Gặp

**1. Lỗi SSL Certificate:**
```dart
// main.dart đã bỏ qua SSL cho development
HttpOverrides.global = MyHttpOverrides();
```

**2. Lỗi Kết Nối:**
- Kiểm tra cấu hình API endpoint
- Xác minh kết nối mạng
- Kiểm tra cài đặt mạng của emulator/thiết bị

**3. Token Hết Hạn:**
- Cơ chế tự động refresh sẽ xử lý
- Kiểm tra tính hợp lệ của refresh_token

## 📚 Giải Thích Chi Tiết Cấu Trúc

### 📁 main.dart
**File khởi đầu của ứng dụng**
- Hàm `main()` là điểm vào đầu tiên khi app chạy
- Cấu hình `HttpOverrides` để bypass SSL cho localhost (development)
- Khởi tạo `MaterialApp` với theme, routes
- `AuthenticationWrapper`: Kiểm tra xem user đã đăng nhập chưa
  - Nếu có token hợp lệ → chuyển đến Home
  - Nếu không → chuyển đến Login

### 📁 constants/
**Chứa các hằng số dùng chung trong toàn ứng dụng**
- `api_endpoints.dart`: Định nghĩa tất cả địa chỉ API
- `app_colors.dart`: Màu sắc theme (primary, secondary, accent...)
- `app_texts.dart`: Các văn bản tĩnh, message templates

### 📁 models/
**Định nghĩa cấu trúc dữ liệu (Data Transfer Objects)**
- Mỗi model đại diện cho 1 entity trong hệ thống
- Có phương thức `toJson()` để chuyển object → JSON (gửi API)
- Có factory `fromJson()` để chuyển JSON → object (nhận từ API)
- Ví dụ: `LoginRequest`, `LoginResponse`, `Room`, `Booking`

### 📁 routes/
**Quản lý điều hướng giữa các màn hình**
- Định nghĩa tên routes dạng string (`/home`, `/login`...)
- Map routes với Widget tương ứng
- `onGenerateRoute`: Xử lý routes có parameters (roomId, dates...)
- Helper functions: `navigateTo()`, `goBack()`, `navigateWithArguments()`

### 📁 screens/
**Các màn hình UI của ứng dụng**
Mỗi screen là 1 `StatefulWidget` có:
- UI layout với các widgets
- Form controllers để quản lý input
- Gọi services để lấy/gửi dữ liệu
- Xử lý state (loading, error, success)
- Navigation logic

### 📁 services/
**Lớp logic nghiệp vụ - tương tác với API và xử lý dữ liệu**

**api_service.dart:**
- Wrapper chung cho HTTP requests
- Methods: `get()`, `post()`, `put()`, `delete()`
- Singleton pattern (chỉ 1 instance duy nhất)
- Xử lý response và errors

**auth_service.dart:**
- Xử lý login/register/logout
- Lưu/lấy/xóa tokens từ storage
- Kiểm tra trạng thái đăng nhập

**http_interceptor.dart:**
- Intercept (chặn) mọi HTTP request trước khi gửi
- Tự động thêm `Authorization: Bearer {token}` vào headers
- Nếu nhận response 401 (Unauthorized):
  - Gọi API refresh token
  - Lưu token mới
  - Thử lại request ban đầu
- Đây là tính năng **quan trọng** giúp UX mượt mà

**room_service.dart, booking_service.dart, category_service.dart:**
- Gọi API cụ thể cho từng domain
- Parse response thành models
- Error handling cụ thể

**local_storage.dart:**
- Wrapper cho `SharedPreferences`
- Lưu trữ token, user info vào bộ nhớ thiết bị
- Dữ liệu không mất khi tắt app

### 📁 utils/
**Các hàm tiện ích helper**
- `format_date.dart`: Format DateTime thành string đẹp
- `jwt_helper.dart`: Decode JWT, kiểm tra expiry time

### 📁 widgets/
**Các UI component tái sử dụng**
- `custom_button.dart`: Button với style nhất quán
- `custom_textfield.dart`: Input field với validation
- `custom_bottom_nav.dart`: Bottom navigation bar

**Lợi ích:** Tránh duplicate code, dễ maintain

## � Luồng Hoạt Động Chi Tiết

### 1. Khởi động App
```
1. main() được gọi
2. MaterialApp khởi tạo
3. AuthenticationWrapper render
4. Gọi AuthService.isLoggedIn()
   → Đọc token từ SharedPreferences
   → Kiểm tra token có tồn tại và còn hạn không
5. Navigate đến màn hình phù hợp
```

### 2. User Đăng Nhập
```
1. User nhập email, password vào LoginScreen
2. Nhấn button Login
3. Validate form (email format, required fields)
4. Gọi AuthService.login(email, password)
   → HTTP POST đến /api/Auth/Login
5. Backend xác thực và trả về tokens
6. AuthService lưu tokens vào LocalStorage
7. Navigate đến HomeScreen
8. Show success message
```

### 3. Gọi API Có Authentication
```
1. Screen gọi Service (vd: RoomService.getAllRooms())
2. Service gọi ApiService.get(url)
3. ApiService gọi HttpInterceptor.request()
4. HttpInterceptor:
   → Lấy access_token từ LocalStorage
   → Thêm vào header: Authorization: Bearer {token}
   → Gửi request
5. Nếu response 200 → trả về data
6. Nếu response 401 (token hết hạn):
   → Gọi API RefreshToken với refresh_token
   → Lưu access_token mới
   → Retry request ban đầu
   → Trả về data
7. Service parse JSON → Model
8. Screen nhận data và update UI
```

### 4. Luồng Đặt Phòng
```
1. HomeScreen: User chọn Category
2. Navigate đến RoomsScreen với categoryId
3. RoomsScreen: Hiển thị danh sách phòng
4. User tap vào 1 phòng
5. Navigate đến RoomDetailScreen với roomId
6. RoomDetailScreen: Hiển thị thông tin chi tiết
7. User nhấn "Đặt phòng"
8. Navigate đến CreateBookingScreen
9. User chọn ngày checkin, checkout
10. Nhấn "Xác nhận"
11. Validate dates
12. Gọi BookingService.createBooking()
    → API POST /api/Bookings
13. Show success/error message
14. Navigate đến BookingScreen (danh sách bookings)
```

## 💡 Tips và Best Practices

### Khi Phát Triển
- Luôn check `mounted` trước khi gọi `setState()` sau async
- Dispose controllers trong `dispose()`
- Sử dụng `const` constructor khi có thể
- Handle loading state và errors
- Show feedback cho user (SnackBar, Dialog)

### Khi Debug
- Dùng `flutter run -v` để xem logs chi tiết
- Check terminal output để thấy API responses
- Dùng Dart DevTools để debug
- Check SharedPreferences để xem tokens đã lưu chưa

### Khi Deploy
- Đổi `baseUrl` sang production API
- Remove SSL bypass trong `main.dart`
- Build release mode: `flutter build apk --release`
- Test kỹ trên nhiều thiết bị

## 📄 License

Dự án này là private và không được publish lên pub.dev.

## 👥 Đóng Góp

- Development Team - Sweet Hotel

## 📞 Hỗ Trợ

Nếu cần hỗ trợ, vui lòng liên hệ team phát triển hoặc tạo issue trong repository.

---

**Được xây dựng với ❤️ bằng Flutter**
