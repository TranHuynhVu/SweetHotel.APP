import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/rooms_screen.dart';
import '../screens/room_detail_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/create_booking_screen.dart';
import '../screens/booking_detail_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  // Tên các route
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String rooms = '/rooms';
  static const String roomDetail = '/room-detail';
  static const String booking = '/booking';
  static const String createBooking = '/create-booking';
  static const String bookingDetail = '/booking-detail';
  static const String profile = '/profile';

  // Map các route với màn hình tương ứng
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      rooms: (context) => const RoomsScreen(),
      profile: (context) => const ProfileScreen(),
    };
  }

  // Route generator để xử lý routes có parameters
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case roomDetail:
        final roomId = settings.arguments as String?;
        if (roomId == null) {
          return null;
        }
        return MaterialPageRoute(
          builder: (context) => RoomDetailScreen(roomId: roomId),
        );
      case booking:
        // Không nhận arguments, chỉ hiển thị danh sách bookings
        return MaterialPageRoute(builder: (context) => const BookingScreen());
      case createBooking:
        // Xử lý arguments: có thể là String (roomId) hoặc Map (roomId + dates)
        final arguments = settings.arguments;

        if (arguments is String) {
          // Chỉ có roomId
          return MaterialPageRoute(
            builder: (context) =>
                CreateBookingScreen(preSelectedRoomId: arguments),
          );
        } else if (arguments is Map<String, dynamic>) {
          // Có cả roomId và dates
          return MaterialPageRoute(
            builder: (context) => CreateBookingScreen(
              preSelectedRoomId: arguments['roomId'] as String?,
              preSelectedStartDate: arguments['startDate'] as DateTime?,
              preSelectedEndDate: arguments['endDate'] as DateTime?,
            ),
          );
        }
        // Không có arguments
        return MaterialPageRoute(
          builder: (context) => const CreateBookingScreen(),
        );
      case bookingDetail:
        final bookingId = settings.arguments as String?;
        if (bookingId == null) {
          return null;
        }
        return MaterialPageRoute(
          builder: (context) => BookingDetailScreen(bookingId: bookingId),
        );
      default:
        return null;
    }
  }

  // Route ban đầu khi khởi động app
  static const String initialRoute = home;

  // Hàm điều hướng đến màn hình mới
  static Future<dynamic> navigateTo(BuildContext context, String routeName) {
    return Navigator.pushNamed(context, routeName);
  }

  // Hàm điều hướng và xóa tất cả route trước đó
  static Future<dynamic> navigateAndRemoveUntil(
    BuildContext context,
    String routeName,
  ) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }

  // Hàm quay lại màn hình trước
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  // Hàm điều hướng với arguments
  static Future<dynamic> navigateWithArguments(
    BuildContext context,
    String routeName,
    Object arguments,
  ) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }
}
