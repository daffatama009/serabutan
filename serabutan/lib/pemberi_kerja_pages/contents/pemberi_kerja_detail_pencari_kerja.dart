import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';

class DetailPencariKerjaPage extends StatefulWidget {
  final int idPencariKerja;

  const DetailPencariKerjaPage({super.key, required this.idPencariKerja});

  @override
  State<DetailPencariKerjaPage> createState() => _DetailPencariKerjaPageState();
}

class _DetailPencariKerjaPageState extends State<DetailPencariKerjaPage> {
  Map<String, dynamic> _pencariKerja = {};

  @override
  void initState() {
    super.initState();
    _fetchDetailPencariKerja();
  }

  Future<void> _fetchDetailPencariKerja() async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + 'detail_pencari_kerja.php'),
        body: {
          'id_pencari_kerja': widget.idPencariKerja.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          setState(() {
            _pencariKerja = responseJson['data'];
            // Ensure all values are converted to strings if necessary
            _pencariKerja = _pencariKerja.map((key, value) {
              return MapEntry(key, value.toString());
            });
          });
        } else {
          Fluttertoast.showToast(
              msg:
                  'Gagal memuat detail pencari kerja: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal memuat detail pencari kerja: Server error dengan kode ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memuat detail pencari kerja: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pencariKerja.isNotEmpty
              ? _pencariKerja['nama_pencari_kerja']
              : 'Detail Pencari Kerja',
        ),
      ),
      body: _pencariKerja.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          Config.fotoProfilePencariKerjaUrl +
                              _pencariKerja['foto']),
                      radius: 60,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailCard(
                    title: 'Nama',
                    value: _pencariKerja['nama_pencari_kerja'],
                  ),
                  _buildDetailCard(
                    title: 'Umur',
                    value: _pencariKerja['umur'],
                  ),
                  _buildDetailCard(
                    title: 'Alamat',
                    value: _pencariKerja['alamat'],
                  ),
                  _buildDetailCard(
                    title: 'No Telepon',
                    value: _pencariKerja['no_telepon'],
                  ),
                  _buildDetailCard(
                    title: 'Total Rating',
                    value: _pencariKerja['total_rating'],
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDetailCard({required String title, required String value}) {
    return Card(
      color: const Color(0xFFF1F1F1), // Light gray background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF333333), // Dark text color
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue // Primary color
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
