import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:serabutan/pemberi_kerja_pages/pemberi_kerja_homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PemberiKerjaLogin extends StatefulWidget {
  @override
  _PemberiKerjaLoginState createState() => _PemberiKerjaLoginState();
}

class _PemberiKerjaLoginState extends State<PemberiKerjaLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginPemberiKerja() async {
    try {
      final response = await http.post(
        Uri.parse(Config.loginPemberiKerjaUrl),
        body: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id_pemberi_kerja', responseJson['user']['id']);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PemberiKerjaHomepage(),
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
        title: Text('Login Pemberi Kerja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Login Pemberi Kerja',
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
              onPressed: _loginPemberiKerja,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/pemberi_kerja_registrasi');
              },
              child: Text('Belum punya akun? Registrasi di sini'),
            ),
          ],
        ),
      ),
    );
  }
}
