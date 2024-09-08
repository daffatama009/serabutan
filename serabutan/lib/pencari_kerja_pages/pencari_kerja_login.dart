import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:serabutan/pencari_kerja_pages/pencari_kerja_homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PencariKerjaLogin extends StatefulWidget {
  @override
  _PencariKerjaLoginState createState() => _PencariKerjaLoginState();
}

class _PencariKerjaLoginState extends State<PencariKerjaLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginPencariKerja() async {
    try {
      final response = await http.post(
        Uri.parse(Config.loginPencariKerjaUrl),
        body: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id_pencari_kerja', responseJson['user']['id']);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PencariKerjaHomepage(),
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: 'Login gagal: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Login gagal: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Login gagal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Pencari Kerja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Login Pencari Kerja',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginPencariKerja,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/pencari_kerja_registrasi');
              },
              child: Text('Belum punya akun? Registrasi di sini'),
            ),
          ],
        ),
      ),
    );
  }
}
