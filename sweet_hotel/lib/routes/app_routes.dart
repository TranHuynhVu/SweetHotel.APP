import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/rooms_screen.dart';

class AppRoutes {
  // Tên các route
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String rooms = '/rooms';

  // Map các route với màn hình tương ứng
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      rooms: (context) => const RoomsScreen(),
    };
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
