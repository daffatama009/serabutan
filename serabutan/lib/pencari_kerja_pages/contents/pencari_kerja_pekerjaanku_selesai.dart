import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:serabutan/config.dart';
import 'package:serabutan/pencari_kerja_pages/contents/pencari_kerja_detail_pekerjaanku_selesai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PencariKerjaPekerjaankuSelesaiPage extends StatefulWidget {
  const PencariKerjaPekerjaankuSelesaiPage({super.key});

  @override
  State<PencariKerjaPekerjaankuSelesaiPage> createState() =>
      _PencariKerjaPekerjaankuSelesaiPageState();
}

class _PencariKerjaPekerjaankuSelesaiPageState
    extends State<PencariKerjaPekerjaankuSelesaiPage> {
  List<dynamic> _pekerjaanSelesaiList = [];

  @override
  void initState() {
    super.initState();
    _fetchPekerjaanSelesai();
  }

  Future<void> _fetchPekerjaanSelesai() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idPencariKerja = prefs.getInt('id_pencari_kerja');

    if (idPencariKerja != null) {
      try {
        final response = await http.post(
          Uri.parse(
              Config.baseUrl + "ambil_pekerjaanku_selesai_pencari_kerja.php"),
          body: {
            'id_pencari_kerja': idPencariKerja.toString(),
          },
        );

        if (response.statusCode == 200) {
          final responseJson = jsonDecode(response.body);
          if (responseJson['status'] == 'success') {
            setState(() {
              _pekerjaanSelesaiList = responseJson['data'];
            });
          } else {
            // Handle error response
            print('Error: ${responseJson['message']}');
          }
        } else {
          print('Server Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('User ID not found in preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pekerjaanSelesaiList.isEmpty
          ? const Center(child: Text('Belum ada pekerjaan selesai.'))
          : ListView.builder(
              itemCount: _pekerjaanSelesaiList.length,
              itemBuilder: (context, index) {
                final pekerjaan = _pekerjaanSelesaiList[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      Config.fotoPekerjaanUrl + pekerjaan['foto_pekerjaan'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    title: Text(pekerjaan['nama_pekerjaan']),
                    subtitle: Text('Status: ${pekerjaan['status']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PencariKerjaDetailPekerjaankuSelesaiPage(
                                  idPekerjaan: pekerjaan['id_pekerjaan']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
