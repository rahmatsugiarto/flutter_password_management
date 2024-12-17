import 'package:flutter/material.dart';
import 'package:flutter_password_management/core/aes_helper.dart';
import 'package:flutter_password_management/core/custom_text_form_field.dart';
import 'package:flutter_password_management/db/db_helper.dart';
import 'package:flutter_password_management/main.dart';
import 'package:flutter_password_management/models/password.dart';

class PasswordScreen extends StatefulWidget {
  final int userId;
  const PasswordScreen({super.key, required this.userId});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  List<Password> _passwords = [];

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    final db = await DBHelper().database;
    final List<Map<String, dynamic>> results = await db.query(
      'passwords',
      where: 'userId = ?',
      whereArgs: [widget.userId],
    );
    setState(() {
      _passwords = results.map((map) => Password.fromMap(map)).toList();
    });
  }

  Future<void> _addOrEditPassword({Password? password}) async {
    final titleController =
        TextEditingController(text: password != null ? password.title : '');
    final usernameController =
        TextEditingController(text: password != null ? password.username : '');
    final passwordController = TextEditingController(
        text: password != null ? AESHelper.decrypt(password.password) : '');

    bool isNotReady = titleController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(password == null ? 'Add New Password' : 'Edit Password'),
          content: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: titleController,
                  labelText: "Title",
                  hintText: "Enter title",
                  onChanged: (_) {
                    isNotReady = titleController.text.trim().isEmpty ||
                        usernameController.text.trim().isEmpty ||
                        passwordController.text.trim().isEmpty;
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: usernameController,
                  labelText: "Username",
                  hintText: "Enter username",
                  onChanged: (_) {
                    isNotReady = titleController.text.trim().isEmpty ||
                        usernameController.text.trim().isEmpty ||
                        passwordController.text.trim().isEmpty;
                    setState(() {});
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: passwordController,
                  labelText: "Password",
                  hintText: "Enter your password",
                  obscureText: true,
                  onChanged: (_) {
                    isNotReady = titleController.text.trim().isEmpty ||
                        usernameController.text.trim().isEmpty ||
                        passwordController.text.trim().isEmpty;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isNotReady
                  ? null
                  : () async {
                      final db = await DBHelper().database;
                      if (password == null) {
                        final passwordEncrypt = AESHelper.encrypt(
                          passwordController.text.trim(),
                        );

                        await db.insert('passwords', {
                          'userId': widget.userId,
                          'title': titleController.text.trim(),
                          'username': usernameController.text.trim(),
                          'password': passwordEncrypt,
                        });
                      } else {
                        final passwordEncrypt = AESHelper.encrypt(
                          passwordController.text.trim(),
                        );

                        await db.update(
                          'passwords',
                          {
                            'title': titleController.text.trim(),
                            'username': usernameController.text.trim(),
                            'password': passwordEncrypt,
                          },
                          where: 'id = ? AND userId = ?',
                          whereArgs: [password.id, widget.userId],
                        );
                      }
                      Navigator.pop(navigatorKey.currentContext ?? context);
                      _loadPasswords();
                    },
              child: Text(password == null ? 'Add' : 'Save'),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _deletePassword(Password password) async {
    final db = await DBHelper().database;
    await db.delete(
      'passwords',
      where: 'id = ? AND userId = ?',
      whereArgs: [password.id, widget.userId],
    );
    _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Passwords')),
      body: Builder(builder: (context) {
        if (_passwords.isEmpty) {
          return const Center(
            child: Text(
              "No Password Saved Yet ",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: _passwords.length,
          itemBuilder: (context, index) {
            final password = _passwords[index];

            return ListTile(
              title: Text(password.title),
              subtitle: Text(password.username),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _addOrEditPassword(password: password),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePassword(password),
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditPassword(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
