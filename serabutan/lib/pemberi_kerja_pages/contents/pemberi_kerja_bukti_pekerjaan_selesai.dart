import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';

class PemberiKerjaBuktiPekerjaanSelesaiPage extends StatefulWidget {
  final int idPekerjaan;
  final int idPencariKerja;

  const PemberiKerjaBuktiPekerjaanSelesaiPage(
      {super.key, required this.idPekerjaan, required this.idPencariKerja});

  @override
  State<PemberiKerjaBuktiPekerjaanSelesaiPage> createState() =>
      _PemberiKerjaBuktiPekerjaanSelesaiPageState();
}

class _PemberiKerjaBuktiPekerjaanSelesaiPageState
    extends State<PemberiKerjaBuktiPekerjaanSelesaiPage> {
  Map<String, dynamic>? _buktiPekerjaan;

  @override
  void initState() {
    super.initState();
    _fetchBuktiPekerjaan();
  }

  Future<void> _fetchBuktiPekerjaan() async {
    try {
      final response = await http.post(
        Uri.parse(
            Config.baseUrl + 'ambil_bukti_pekerjaan_selesai_pemberi_kerja.php'),
        body: {
          'id_pekerjaan': widget.idPekerjaan.toString(),
          'id_pencari_kerja': widget.idPencariKerja.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          setState(() {
            _buktiPekerjaan = responseJson['data'];
          });
        } else {
          setState(() {
            _buktiPekerjaan = null;
          });
          Fluttertoast.showToast(
              msg: 'Gagal memuat bukti pekerjaan: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal memuat bukti pekerjaan: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memuat bukti pekerjaan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bukti Pekerjaan Selesai"),
      ),
      body: _buktiPekerjaan == null
          ? const Center(
              child: Text(
                "Pekerja belum beri bukti",
                style: TextStyle(color: Color(0xFF333333)), // Dark text color
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: const Color(0xFFF1F1F1), // Light gray background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Nama Pekerjaan:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333), // Dark text color
                        ),
                      ),
                      Text(
                        _buktiPekerjaan!['nama_pekerjaan'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4CAF50), // Primary color
                        ),
                      ),
                      const SizedBox(height: 16),
                      Image.network(
                        Config.fotoBuktiPekerjaanUrl +
                            _buktiPekerjaan!['foto_bukti'],
                        height: 250,
                        width: 250,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailItem(
                              'Tanggal Selesai',
                              _buktiPekerjaan!['tanggal_selesai'],
                              Icons.calendar_today),
                          _buildDetailItem(
                              'Waktu Selesai',
                              _buktiPekerjaan!['waktu_selesai'],
                              Icons.access_time),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDetailItem(
                        'Nama Pencari Kerja',
                        _buktiPekerjaan!['nama_pencari_kerja'],
                        Icons.person,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF4CAF50), // Primary color
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333), // Dark text color
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF5722), // Accent color
              ),
            ),
          ],
        ),
      ],
    );
  }
}
