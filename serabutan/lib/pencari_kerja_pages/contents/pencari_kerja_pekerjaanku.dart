import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:serabutan/pencari_kerja_pages/contents/pencari_kerja_detail_pekerjaanku.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';

class PencariKerjaPekerjaankuPage extends StatefulWidget {
  const PencariKerjaPekerjaankuPage({super.key});

  @override
  State<PencariKerjaPekerjaankuPage> createState() =>
      _PencariKerjaPekerjaankuPageState();
}

class _PencariKerjaPekerjaankuPageState
    extends State<PencariKerjaPekerjaankuPage> {
  List<dynamic> _pekerjaanList = [];

  @override
  void initState() {
    super.initState();
    _fetchPekerjaanku();
  }

  Future<void> _fetchPekerjaanku() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idPencariKerja = prefs.getInt('id_pencari_kerja');

      if (idPencariKerja == null) {
        Fluttertoast.showToast(msg: 'Gagal mengambil id pencari kerja');
        return;
      }

      final response = await http.post(
        Uri.parse(Config.baseUrl + 'ambil_pekerjaanku_pencari_kerja.php'),
        body: {
          'id_pencari_kerja': idPencariKerja.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          setState(() {
            _pekerjaanList = responseJson['data'];
          });
        } else {
          Fluttertoast.showToast(
              msg: 'Gagal memuat pekerjaan: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal memuat pekerjaan: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memuat pekerjaan: $e');
    }
  }

  Widget _buildJobCard(Map<String, dynamic> pekerjaan) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                Config.baseUrl +
                    'uploads/foto_pekerjaan/' +
                    pekerjaan['foto_pekerjaan'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pekerjaan['nama_pekerjaan'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Bayaran: ${pekerjaan['bayaran']}'),
                  Text('Tanggal: ${pekerjaan['tanggal']}'),
                  Text('Waktu: ${pekerjaan['waktu']}'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PencariKerjaDetailPekerjaankuPage(
                      idPekerjaan: pekerjaan['id_pekerjaan'],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pekerjaanList.isEmpty
          ? const Center(child: Text('Belum ada pekerjaanku.'))
          : ListView.builder(
              itemCount: _pekerjaanList.length,
              itemBuilder: (context, index) {
                var pekerjaan = _pekerjaanList[index];
                return _buildJobCard(pekerjaan);
              },
            ),
    );
  }
}
