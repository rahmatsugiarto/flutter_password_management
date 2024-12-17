import 'package:flutter/material.dart';
import 'package:flutter_password_management/core/route_name.dart';
import 'package:flutter_password_management/screens/login_screen.dart';
import 'package:flutter_password_management/screens/register_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: RouteName.loginScreen,
      routes: {
        RouteName.loginScreen: (context) => const LoginScreen(),
        RouteName.registerScreen: (context) => const RegisterScreen(),
      },
    );
  }
}
