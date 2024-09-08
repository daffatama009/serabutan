import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:serabutan/pemberi_kerja_pages/contents/pemberi_kerja_detail_pencari_kerja.dart';

class DetailPekerjaanPage extends StatefulWidget {
  final int idPekerjaan;

  const DetailPekerjaanPage({super.key, required this.idPekerjaan});

  @override
  State<DetailPekerjaanPage> createState() => _DetailPekerjaanPageState();
}

class _DetailPekerjaanPageState extends State<DetailPekerjaanPage> {
  String _namaPekerjaan = '';
  List<dynamic> _pencariKerjaList = [];

  @override
  void initState() {
    super.initState();
    _fetchDetailPekerjaan();
  }

  Future<void> _fetchDetailPekerjaan() async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + 'detail_pekerjaan_pemberi_kerja.php'),
        body: {
          'id_pekerjaan': widget.idPekerjaan.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          setState(() {
            _namaPekerjaan = responseJson['data'][0]['nama_pekerjaan'];
            _pencariKerjaList = responseJson['data'];
          });
        } else {
          Fluttertoast.showToast(
              msg: 'Halaman Masih Kosong: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal memuat detail pekerjaan: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memuat detail pekerjaan: $e');
    }
  }

  Future<void> _ubahStatusPengajuan(int idPengajuan, String status) async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + 'ubah_status_pengajuan_pekerjaan.php'),
        body: {
          'id_pengajuan': idPengajuan.toString(),
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          Fluttertoast.showToast(msg: 'Status pengajuan diperbarui');
          _fetchDetailPekerjaan();
        } else {
          Fluttertoast.showToast(
              msg:
                  'Gagal mengubah status pengajuan: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal mengubah status pengajuan: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal mengubah status pengajuan: $e');
    }
  }

  Future<void> _jalankanPekerjaan() async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + 'jalankan_pekerjaan.php'),
        body: {
          'id_pekerjaan': widget.idPekerjaan.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          Fluttertoast.showToast(msg: 'Pekerjaan berjalan');
        } else {
          Fluttertoast.showToast(
              msg: 'Gagal menjalankan pekerjaan: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal menjalankan pekerjaan: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal menjalankan pekerjaan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _namaPekerjaan.isNotEmpty ? _namaPekerjaan : 'Detail Pekerjaan'),
      ),
      body: _pencariKerjaList.isEmpty
          ? Center(
              child: Text(
                'Belum ada pendaftar kerja!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _pencariKerjaList.length,
              itemBuilder: (context, index) {
                var pencariKerja = _pencariKerjaList[index];
                return Card(
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPencariKerjaPage(
                                idPencariKerja:
                                    pencariKerja['id_pencari_kerja']),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            Config.fotoProfilePencariKerjaUrl +
                                pencariKerja['foto']),
                      ),
                    ),
                    title: Text(pencariKerja['nama_pencari_kerja']),
                    trailing: pencariKerja['status_pengajuan'] == 'diterima'
                        ? Text('Diterima',
                            style: TextStyle(color: Colors.green))
                        : pencariKerja['status_pengajuan'] == 'ditolak'
                            ? Text('Ditolak',
                                style: TextStyle(color: Colors.red))
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _ubahStatusPengajuan(
                                          pencariKerja['id_pengajuan'],
                                          'diterima');
                                    },
                                    child: Text('Terima'),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _ubahStatusPengajuan(
                                          pencariKerja['id_pengajuan'],
                                          'ditolak');
                                    },
                                    child: Text('Tolak'),
                                  ),
                                ],
                              ),
                  ),
                );
              },
            ),
      bottomNavigationBar: ElevatedButton(
          onPressed: _jalankanPekerjaan, child: Text("jalankan pekerjaan")),
    );
  }
}
