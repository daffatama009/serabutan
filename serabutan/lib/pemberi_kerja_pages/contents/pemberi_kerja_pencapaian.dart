import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serabutan/config.dart';

class PemberiKerjaPencapaianPage extends StatefulWidget {
  @override
  _PemberiKerjaPencapaianPageState createState() =>
      _PemberiKerjaPencapaianPageState();
}

class _PemberiKerjaPencapaianPageState
    extends State<PemberiKerjaPencapaianPage> {
  late Future<Map<String, dynamic>> pencapaianFuture;

  @override
  void initState() {
    super.initState();
    pencapaianFuture = _fetchPencapaian();
  }

  Future<Map<String, dynamic>> _fetchPencapaian() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idPemberiKerja = prefs.getInt('id_pemberi_kerja');

    final response = await http.post(
      Uri.parse(Config.baseUrl + 'ambil_pencapaian_pemberi_kerja.php'),
      body: {'id_pemberi_kerja': idPemberiKerja.toString()},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load achievements');
    }
  }

  Widget _buildAchievementCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: pencapaianFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan.'));
          } else {
            final pencapaian = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildAchievementCard(
                    'Total Pekerjaan Dibuat',
                    pencapaian['total_jobs_created'].toString(),
                    Icons.work_outline,
                    Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  _buildAchievementCard(
                    'Total Lamaran Pekerja',
                    pencapaian['total_job_seeker_applications'].toString(),
                    Icons.people_outline,
                    Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _buildAchievementCard(
                    'Total Pekerja Diterima',
                    pencapaian['total_job_seekers_accepted'].toString(),
                    Icons.check_circle_outline,
                    Colors.orange,
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
