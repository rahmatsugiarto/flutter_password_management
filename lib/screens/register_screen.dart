import 'package:flutter/material.dart';
import 'package:flutter_password_management/core/aes_helper.dart';
import 'package:flutter_password_management/core/custom_text_form_field.dart';
import 'package:flutter_password_management/db/db_helper.dart';
import 'package:flutter_password_management/main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    final db = await DBHelper().database;
    try {
      final passwordEncrypt = AESHelper.encrypt(
        _passwordController.text.trim(),
      );

      await db.insert('users', {
        'full_name': _usernameController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': passwordEncrypt,
      });
      ScaffoldMessenger.of(navigatorKey.currentContext ?? context)
          .showSnackBar(const SnackBar(
        content: Text('User registered successfully!'),
      ));
      Navigator.pop(navigatorKey.currentContext ?? context);
    } catch (e) {
      ScaffoldMessenger.of(navigatorKey.currentContext ?? context)
          .showSnackBar(const SnackBar(
        content: Text('Registration failed: Username might already exist!'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextFormField(
              controller: _fullNameController,
              labelText: "Full Name",
              hintText: "Enter your full name",
            ),
            const SizedBox(
              height: 8.0,
            ),
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
              onPressed: _register,
              child: const Text('Register'),
            ),
            const SizedBox(
              height: 8.0,
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
