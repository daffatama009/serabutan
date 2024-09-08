import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:serabutan/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PencariKerjaDetailPekerjaanPage extends StatefulWidget {
  final int idPekerjaan;

  const PencariKerjaDetailPekerjaanPage({super.key, required this.idPekerjaan});

  @override
  State<PencariKerjaDetailPekerjaanPage> createState() =>
      _PencariKerjaDetailPekerjaanPageState();
}

class _PencariKerjaDetailPekerjaanPageState
    extends State<PencariKerjaDetailPekerjaanPage> {
  late Future<Map<String, dynamic>> _jobDetailFuture;
  bool hasApplied = false;

  @override
  void initState() {
    super.initState();
    _jobDetailFuture = fetchJobDetail(widget.idPekerjaan);
    checkIfAlreadyApplied();
  }

  Future<Map<String, dynamic>> fetchJobDetail(int idPekerjaan) async {
    try {
      final response = await http.get(
        Uri.parse(Config.baseUrl +
            'detail_pekerjaan_pencari_kerja.php?id_pekerjaan=$idPekerjaan'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load job detail');
      }
    } catch (e) {
      print('Error fetching job detail: $e');
      throw Exception('Error fetching job detail');
    }
  }

  Future<int?> getPencariKerjaId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_pencari_kerja');
  }

  Future<void> checkIfAlreadyApplied() async {
    final int? idPencariKerja = await getPencariKerjaId();
    if (idPencariKerja == null) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + 'cek_pengajuan_pekerjaan.php'),
        body: {
          'id_pekerjaan': widget.idPekerjaan.toString(),
          'id_pencari_kerja': idPencariKerja.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('applied') &&
            responseData['applied'] == true) {
          setState(() {
            hasApplied = true;
          });
        }
      }
    } catch (e) {
      print('Error checking application status: $e');
    }
  }

  Future<void> applyForJob(int idPekerjaan) async {
    final int? idPencariKerja = await getPencariKerjaId();
    if (idPencariKerja == null) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + 'daftar_pekerjaan_pencari_kerja.php'),
        body: {
          'id_pekerjaan': idPekerjaan.toString(),
          'id_pencari_kerja': idPencariKerja.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Gagal Daftar')),
        );
      }
    } catch (e) {
      print('Error applying for job: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal Daftar Pekerjaan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pekerjaan'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _jobDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Tidak Ada Pekerjaan.'));
          } else {
            final job = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Image
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        Config.baseUrl +
                            'uploads/foto_pekerjaan/' +
                            job['foto_pekerjaan'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Job Information
                  Text(
                    job['nama_pekerjaan'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bayaran: ${job['bayaran']}',
                    style: const TextStyle(
                        fontSize: 18, color: Color(0xFF333333)), // Text Color
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal: ${job['tanggal']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waktu: ${job['waktu']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alamat: ${job['alamat']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Job Description
                  const Text(
                    'Deskripsi Pekerjaan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['deskripsi'],
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  // Employer Information
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F1), // Secondary Color
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pemberi Kerja',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nama: ${job['nama_pemberi_kerja']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No. Telepon: ${job['no_telepon']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Apply Button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasApplied
                            ? Colors.grey
                            : const Color(0xFFFF5722), // Accent Color
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 32.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: hasApplied
                          ? null
                          : () => applyForJob(widget.idPekerjaan),
                      child: Text(
                        hasApplied ? 'Anda sudah mendaftar' : 'Daftar Sekarang',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
