import 'package:flutter/material.dart';
import 'package:flutter_password_management/core/aes_helper.dart';
import 'package:flutter_password_management/core/custom_text_form_field.dart';
import 'package:flutter_password_management/core/route_name.dart';
import 'package:flutter_password_management/db/db_helper.dart';
import 'package:flutter_password_management/main.dart';
import 'package:flutter_password_management/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final db = await DBHelper().database;

    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [_usernameController.text],
    );

    if (result.isNotEmpty) {
      final String encryptedPassword = result.first['password'].toString();

      final decryptedPassword = AESHelper.decrypt(encryptedPassword);

      if (decryptedPassword == _passwordController.text) {
        // Login Success
        final userId = result.first['id'] as int;
        Navigator.pushReplacement(
          navigatorKey.currentContext ?? context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userId: userId),
          ),
        );
      } else {
        // Wrong Password
        ScaffoldMessenger.of(navigatorKey.currentContext ?? context)
            .showSnackBar(
          const SnackBar(
            content: Text('Invalid username or password'),
          ),
        );
      }
    } else {
      // Username not found
      ScaffoldMessenger.of(navigatorKey.currentContext ?? context).showSnackBar(
        const SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextFormField(
              controller: _usernameController,
              labelText: "Username",
              hintText: "Enter your username",
            ),
            const SizedBox(
              height: 8.0,
            ),
            CustomTextFormField(
              controller: _passwordController,
              labelText: "Password",
              hintText: "Enter your Password",
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteName.registerScreen);
              },
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
