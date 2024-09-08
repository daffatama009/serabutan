import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:serabutan/config.dart';

class PencariKerjaPencapaianPage extends StatefulWidget {
  const PencariKerjaPencapaianPage({super.key});

  @override
  State<PencariKerjaPencapaianPage> createState() =>
      _PencariKerjaPencapaianPageState();
}

class _PencariKerjaPencapaianPageState
    extends State<PencariKerjaPencapaianPage> {
  late Future<Map<String, dynamic>> pencapaianFuture;

  @override
  void initState() {
    super.initState();
    pencapaianFuture = _fetchPencapaian();
  }

  Future<Map<String, dynamic>> _fetchPencapaian() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idPencariKerja = prefs.getInt('id_pencari_kerja');

    final response = await http.post(
      Uri.parse(Config.baseUrl + 'ambil_pencapaian_pencari_kerja.php'),
      body: {'id_pencari_kerja': idPencariKerja.toString()},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Pencapaian Saya'),
      //   centerTitle: true,
      // ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAchievementCard(
                    icon: Icons.check_circle_outline,
                    title: 'Total Pekerjaan Selesai',
                    value: pencapaian['total_jobs_completed'].toString(),
                  ),
                  const SizedBox(height: 16),
                  _buildRatingRow(pencapaian['average_rating']),
                  const SizedBox(height: 16),
                  _buildAchievementCard(
                    icon: Icons.feedback_outlined,
                    title: 'Total Feedback',
                    value: pencapaian['total_feedback_count'].toString(),
                  ),
                  const SizedBox(height: 16),
                  _buildAchievementCard(
                    icon: Icons.attach_money,
                    title: 'Total Penghasilan',
                    value: 'Rp ${pencapaian['total_earnings']}',
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAchievementCard(
      {required IconData icon, required String title, required String value}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(dynamic rating) {
    // Convert rating to double if possible, otherwise use 0.0
    double ratingValue = 0.0;
    if (rating is String) {
      ratingValue = double.tryParse(rating) ?? 0.0;
    } else if (rating is double) {
      ratingValue = rating;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.star, size: 30, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rata-rata Rating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ratingValue.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
