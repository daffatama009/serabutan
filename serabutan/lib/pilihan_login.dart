import 'package:flutter/material.dart';

class PilihanLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilihan Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Login sebagai',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman login pemberi kerja
                Navigator.pushNamed(context, '/pemberi_kerja_login');
              },
              child: Text('Login sebagai Pemberi Kerja'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman login pencari kerja
                Navigator.pushNamed(context, '/pencari_kerja_login');
              },
              child: Text('Login sebagai Pencari Kerja'),
            ),
          ],
        ),
      ),
    );
  }
}
