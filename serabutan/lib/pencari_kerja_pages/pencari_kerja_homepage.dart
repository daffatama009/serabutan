import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:serabutan/pencari_kerja_pages/contents/pencari_kerja_pekerjaanku_selesai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serabutan/pencari_kerja_pages/contents/pencari_kerja_pekerjaanku.dart';
import 'package:serabutan/pencari_kerja_pages/contents/pencari_kerja_daftar_pekerjaan.dart';
import 'package:serabutan/pencari_kerja_pages/contents/pencari_kerja_pencapaian.dart';

class PencariKerjaHomepage extends StatefulWidget {
  @override
  _PencariKerjaHomepageState createState() => _PencariKerjaHomepageState();
}

class _PencariKerjaHomepageState extends State<PencariKerjaHomepage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idPencariKerja = prefs.getInt('id_pencari_kerja');

    if (idPencariKerja != null) {
      try {
        final response = await http.post(
          Uri.parse(Config.ambilDataPencariKerjaUrl),
          body: {
            'id_pencari_kerja': idPencariKerja.toString(),
          },
        );

        if (response.statusCode == 200) {
          final responseJson = jsonDecode(response.body);
          if (responseJson['status'] == 'success') {
            return {
              'userName': responseJson['user']['nama'],
              'userPhotoUrl': responseJson['user']['foto'] != null &&
                      responseJson['user']['foto'].isNotEmpty
                  ? Config.fotoProfilePencariKerjaUrl +
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
          await prefs.remove('id_pencari_kerja');
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
      PencariKerjaPencapaianPage(),
      PencariKerjaDaftarPekerjaanPage(),
      PencariKerjaPekerjaankuPage(),
      PencariKerjaPekerjaankuSelesaiPage()
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Gagal memuat data pengguna.'));
          } else {
            final userName = snapshot.data!['userName'];
            final userPhotoUrl = snapshot.data!['userPhotoUrl'];

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.blueAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: userPhotoUrl.isNotEmpty
                                ? NetworkImage(userPhotoUrl)
                                : AssetImage('assets/placeholder.png'),
                            radius: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            userName,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _logout,
                        child: Text('Logout'),
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
            icon: Icon(Icons.business_center),
            label: 'Pekerjaan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Pekerjaanku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Pekerjaanku Selesai',
          ),
        ],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 58, 102, 221),
        onTap: _onItemTapped,
      ),
    );
  }
}
