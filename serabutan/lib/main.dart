import 'package:flutter/material.dart';
// import 'package:serabutan/pemberi_kerja_pages/contents/detail_pekerjaan.dart';
import 'package:serabutan/pemberi_kerja_pages/contents/tambah_pekerjaan.dart';
import 'package:serabutan/pemberi_kerja_pages/pemberi_kerja_login.dart';
import 'package:serabutan/pemberi_kerja_pages/pemberi_kerja_registrasi.dart';
import 'package:serabutan/pencari_kerja_pages/pencari_kerja_login.dart';
import 'package:serabutan/pencari_kerja_pages/pencari_kerja_registrasi.dart';
import 'pilihan_platform.dart';
import 'pilihan_login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serabutan App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PilihanPlatform(),
      routes: {
        '/pilihan_login': (context) => PilihanLogin(),
        '/pencari_kerja_login': (context) => PencariKerjaLogin(),
        '/pencari_kerja_registrasi': (context) => PencariKerjaRegistrasi(),
        '/pemberi_kerja_login': (context) => PemberiKerjaLogin(),
        '/pemberi_kerja_registrasi': (context) => PemberiKerjaRegistrasi(),
        '/tambah_pekerjaan': (context) => TambahPekerjaanPage(),
        // '/detail_pekerjaan': (context) => DetailPekerjaanPage(idPekerjaan: ),
      },
    );
  }
}
