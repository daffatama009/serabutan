import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contents/pemberi_kerja_pekerjaan_berjalan.dart';
import 'contents/pemberi_kerja_pekerjaan_selesai.dart';
import 'contents/pemberi_kerja_buat_pekerjaan.dart';
import 'contents/pemberi_kerja_pencapaian.dart';

class PemberiKerjaHomepage extends StatefulWidget {
  @override
  _PemberiKerjaHomepageState createState() => _PemberiKerjaHomepageState();
}

class _PemberiKerjaHomepageState extends State<PemberiKerjaHomepage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idPemberiKerja = prefs.getInt('id_pemberi_kerja');

    if (idPemberiKerja != null) {
      try {
        final response = await http.post(
          Uri.parse(Config.ambilDataPemberiKerjaUrl),
          body: {
            'id_pemberi_kerja': idPemberiKerja.toString(),
          },
        );

        if (response.statusCode == 200) {
          final responseJson = jsonDecode(response.body);
          if (responseJson['status'] == 'success') {
            return {
              'userName': responseJson['user']['nama'],
              'userPhotoUrl': responseJson['user']['foto'] != null &&
                      responseJson['user']['foto'].isNotEmpty
                  ? Config.fotoProfilePemberiKerjaUrl +
                      responseJson['user']['foto']
                  : '', // Set URL if valid, otherwise empty string
            };
          } else {
            throw Exception(
                'Gagal memuat data user: ${responseJson['message']}');
          }
        } else {
          throw Exception(
              'Gagal memuat data user: Server error dengan kode ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Gagal memuat data user: $e');
      }
    } else {
      throw Exception('User ID not found in preferences');
    }
  }

  Future<void> _logout() async {
    try {
      final response = await http.post(Uri.parse(Config.logoutUrl));
      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('id_pemberi_kerja');
          Navigator.pushReplacementNamed(context, '/pilihan_login');
        } else {
          Fluttertoast.showToast(
              msg: 'Logout gagal: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Logout gagal: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Logout gagal: $e');
    }
  }

  List<Widget> _pages() {
    return [
      PemberiKerjaPencapaianPage(),
      PemberiKerjaBuatPekerjaanPage(),
      PemberiKerjaPekerjaanBerjalanPage(),
      PemberiKerjaPekerjaanSelesaiPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Homepage Pemberi Kerja'),
      //   automaticallyImplyLeading: false,
      // ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Gagal memuat data pengguna.'));
          } else {
            final userName = snapshot.data!['userName'];
            final userPhotoUrl = snapshot.data!['userPhotoUrl'];

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.blueAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: userPhotoUrl.isNotEmpty
                                ? NetworkImage(userPhotoUrl)
                                : const AssetImage('assets/placeholder.png'),
                            radius: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _logout,
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _pages().elementAt(_selectedIndex),
                ),
              ],
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Homepage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Pekerjaan dibuat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_history),
            label: 'Pekerjaan berjalan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_off),
            label: 'Pekerjaan Selesai',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 3, 7, 250),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
