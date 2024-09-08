import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:serabutan/pemberi_kerja_pages/contents/pemberi_kerja_detail_pekerjaan_berjalan.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
// import 'detail_pekerjaan_page.dart'; // Import halaman detail pekerjaan

class PemberiKerjaPekerjaanBerjalanPage extends StatefulWidget {
  const PemberiKerjaPekerjaanBerjalanPage({super.key});

  @override
  State<PemberiKerjaPekerjaanBerjalanPage> createState() =>
      _PemberiKerjaPekerjaanBerjalanPageState();
}

class _PemberiKerjaPekerjaanBerjalanPageState
    extends State<PemberiKerjaPekerjaanBerjalanPage> {
  List<dynamic> _pekerjaanList = [];

  @override
  void initState() {
    super.initState();
    _fetchPekerjaanBerjalan();
  }

  Future<void> _fetchPekerjaanBerjalan() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idPemberiKerja = prefs.getInt('id_pemberi_kerja');

      if (idPemberiKerja == null) {
        Fluttertoast.showToast(msg: 'Gagal mengambil id pemberi kerja');
        return;
      }

      final response = await http.post(
        Uri.parse(
            Config.baseUrl + 'ambil_pekerjaan_berjalan_pemberi_kerja.php'),
        body: {
          'id_pemberi_kerja': idPemberiKerja.toString(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Title(
                color: Colors.black,
                child: Text(
                  'pekerjaan berjalan',
                  style: TextStyle(fontSize: 20),
                )),
            Expanded(
              child: _pekerjaanList.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada pekerjaan berjalan!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _pekerjaanList.length,
                      itemBuilder: (context, index) {
                        var pekerjaan = _pekerjaanList[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  Config.fotoPekerjaanUrl +
                                      pekerjaan['foto_pekerjaan']),
                            ),
                            title: Text(pekerjaan['nama_pekerjaan']),
                            subtitle: Text(
                                'Jumlah Pekerja: ${pekerjaan['jumlah_pengajuan']}'),
                            trailing: Text(
                              pekerjaan['status_pekerjaan'],
                              style: TextStyle(
                                color:
                                    pekerjaan['status_pekerjaan'] == 'berjalan'
                                        ? Colors.blue
                                        : Colors.green,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PemberiKerjaDetailPekerjaanBerjalanPage(
                                          idPekerjaan:
                                              pekerjaan['id_pekerjaan']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
