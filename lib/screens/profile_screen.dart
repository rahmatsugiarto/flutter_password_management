import 'package:flutter/material.dart';
import 'package:flutter_password_management/db/db_helper.dart';
import 'package:flutter_password_management/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>> _fetchUserData() async {
    final db = await DBHelper().database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [widget.userId],
    );
    return results.isNotEmpty ? results.first : {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('User data not found.'));
          }

          final userData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Full Name: ${userData['full_name']}'),
                Text('Username: ${userData['username']}'),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Clear the stack and navigate to the Login screen
                      Navigator.pushAndRemoveUntil(
                        context,

                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false, // Remove all previous routes
                      );
                    },
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
