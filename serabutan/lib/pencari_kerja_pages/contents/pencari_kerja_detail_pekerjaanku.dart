import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:serabutan/pencari_kerja_pages/contents/pencari_kerja_bukti_pengajuan.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:url_launcher/url_launcher.dart';

class PencariKerjaDetailPekerjaankuPage extends StatefulWidget {
  final int idPekerjaan;

  const PencariKerjaDetailPekerjaankuPage(
      {super.key, required this.idPekerjaan});

  @override
  State<PencariKerjaDetailPekerjaankuPage> createState() =>
      _PencariKerjaDetailPekerjaankuPageState();
}

class _PencariKerjaDetailPekerjaankuPageState
    extends State<PencariKerjaDetailPekerjaankuPage> {
  Map<String, dynamic> _pekerjaanDetail = {};

  @override
  void initState() {
    super.initState();
    _fetchDetailPekerjaanku();
  }

  Future<void> _fetchDetailPekerjaanku() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? idPencariKerja = prefs.getInt('id_pencari_kerja');

      if (idPencariKerja == null) {
        Fluttertoast.showToast(msg: 'Gagal mengambil id pencari kerja');
        return;
      }

      final response = await http.post(
        Uri.parse(Config.baseUrl + 'detail_pekerjaanku_pencari_kerja.php'),
        body: {
          'id_pencari_kerja': idPencariKerja.toString(),
          'id_pekerjaan': widget.idPekerjaan.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          setState(() {
            _pekerjaanDetail = responseJson['data'];
          });
        } else {
          Fluttertoast.showToast(
              msg: 'Gagal memuat detail pekerjaan: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal memuat detail pekerjaan: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memuat detail pekerjaan: $e');
      print('Gagal memuat detail pekerjaan: $e');
    }
  }

  void _ajukanPenyelesaian() async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + 'ubah_status_pengajuan_pekerjaan.php'),
        body: {
          'id_pengajuan': _pekerjaanDetail['id_pengajuan'].toString(),
          'status_pengajuan': 'selesai',
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          Fluttertoast.showToast(msg: 'Penyelesaian berhasil diajukan');
          setState(() {
            _pekerjaanDetail['status_pengajuan'] = 'selesai';
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuktiPengajuanPencariKerjaPage(
                idPekerjaan: widget.idPekerjaan,
                idPengajuan: _pekerjaanDetail['id_pengajuan'],
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: 'Gagal mengajukan penyelesaian: ${responseJson['message']}');
          print('Gagal mengajukan penyelesaian: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal mengajukan penyelesaian: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal mengajukan penyelesaian: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Detail Pekerjaan Ku'), backgroundColor: Colors.blue),
      body: _pekerjaanDetail.isNotEmpty
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      Config.fotoPekerjaanUrl +
                          _pekerjaanDetail['foto_pekerjaan'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 16),
                    Text(
                        'Nama Pekerjaan: ${_pekerjaanDetail['nama_pekerjaan']}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Bayaran: ${_pekerjaanDetail['bayaran']}'),
                    SizedBox(height: 8),
                    Text('Tanggal: ${_pekerjaanDetail['tanggal']}'),
                    SizedBox(height: 8),
                    Text('Waktu: ${_pekerjaanDetail['waktu']}'),
                    SizedBox(height: 8),
                    Text('Deskripsi: ${_pekerjaanDetail['deskripsi']}'),
                    SizedBox(height: 8),
                    Text('Alamat: ${_pekerjaanDetail['alamat']}'),
                    SizedBox(height: 8),
                    Text('Kontak Pemberi Kerja:'),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _launchWhatsApp(_pekerjaanDetail['no_telepon']);
                      },
                      child: Text(
                        _pekerjaanDetail['no_telepon'],
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Status Pekerjaan: ${_pekerjaanDetail['status']}'),
                    SizedBox(height: 16),
                    Text(
                        'Status Pengajuan: ${_pekerjaanDetail['status_pengajuan']}'),
                    SizedBox(height: 16),
                    if (_pekerjaanDetail['status'] == 'berjalan')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BuktiPengajuanPencariKerjaPage(
                                idPekerjaan: widget.idPekerjaan,
                                idPengajuan: _pekerjaanDetail['id_pengajuan'],
                              ),
                            ),
                          );
                        },
                        child: Text('Ajukan Penyelesaian'),
                      )
                    else if (_pekerjaanDetail['status'] == 'dipublish')
                      ElevatedButton(
                        onPressed: null,
                        child: Text('Pekerjaan Belum Dimulai'),
                      )
                    else if (_pekerjaanDetail['status'] == 'Selesai')
                      ElevatedButton(
                        onPressed: null,
                        child: Text('Pekerjaan Selesai'),
                      ),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  void _launchWhatsApp(String phoneNumber) async {
    String formattedNumber = phoneNumber.startsWith('0')
        ? phoneNumber.substring(1) // Remove leading zero
        : phoneNumber;
    String whatsappUrl = 'https://wa.me/62$formattedNumber';

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }
}
