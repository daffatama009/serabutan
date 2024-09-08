import 'package:flutter/material.dart';

class PilihanPlatform extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilihan Platform'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selamat Datang di Serabutan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/pilihan_login');
              },
              child: Text('Lanjut ke Web'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Download aplikasi coming soon!')),
                );
              },
              child: Text('Download Aplikasi'),
            ),
            SizedBox(height: 30),
            Text(
              'Pilih platform yang Anda inginkan untuk melanjutkan menggunakan Serabutan. Aplikasi ini dapat diakses melalui web atau Anda dapat mengunduh aplikasi untuk pengalaman yang lebih baik.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
