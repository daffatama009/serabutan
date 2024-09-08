import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:serabutan/config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PencariKerjaDetailPekerjaankuSelesaiPage extends StatefulWidget {
  final int idPekerjaan;

  const PencariKerjaDetailPekerjaankuSelesaiPage({
    super.key,
    required this.idPekerjaan,
  });

  @override
  State<PencariKerjaDetailPekerjaankuSelesaiPage> createState() =>
      _PencariKerjaDetailPekerjaankuSelesaiPageState();
}

class _PencariKerjaDetailPekerjaankuSelesaiPageState
    extends State<PencariKerjaDetailPekerjaankuSelesaiPage> {
  late Future<Map<String, dynamic>> jobDetailFuture;
  int? _rating;
  bool _isRatingExists = false;

  @override
  void initState() {
    super.initState();
    jobDetailFuture = _fetchJobDetails();
  }

  Future<Map<String, dynamic>> _fetchJobDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idPencariKerja = prefs.getInt('id_pencari_kerja');

    final response = await http.post(
      Uri.parse(
          Config.baseUrl + 'ambil_detail_pekerjaan_selesai_pencari_kerja.php'),
      body: {
        'id_pencari_kerja': idPencariKerja.toString(),
        'id_pekerjaan': widget.idPekerjaan.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          _rating = data['data']['rating'];
          _isRatingExists = _rating != null;
        });
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load job details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue, // Primary color
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: jobDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data not found.'));
          } else {
            final jobDetails = snapshot.data!;
            final rating = jobDetails['rating'];
            final feedback = jobDetails['feedback'];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      Config.fotoPekerjaanUrl + jobDetails['foto_pekerjaan'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Job and Employer Details
                  _buildDetailSection(
                    title: 'Job Details',
                    details: [
                      'Employer: ${jobDetails['nama_pemberi_kerja']}',
                      'Job Name: ${jobDetails['nama_pekerjaan']}',
                      'Payment: ${jobDetails['bayaran']}',
                      'Status: ${jobDetails['status']}',
                    ],
                  ),

                  const SizedBox(height: 16.0),

                  // Rating Section
                  _buildRatingSection(rating),

                  const SizedBox(height: 16.0),

                  // Feedback Section
                  _buildFeedbackSection(feedback),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Helper widget to build detail sections
  Widget _buildDetailSection(
      {required String title, required List<String> details}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333), // Dark gray text color
          ),
        ),
        const SizedBox(height: 8.0),
        ...details.map((detail) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                detail,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333), // Dark gray text color
                ),
              ),
            )),
      ],
    );
  }

  // Helper widget to build rating section
  Widget _buildRatingSection(int? rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(5, (index) {
            return Icon(
              index < (rating ?? 0) ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 32.0,
            );
          }),
        ),
      ],
    );
  }

  // Helper widget to build feedback section
  Widget _buildFeedbackSection(String? feedback) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feedback:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          feedback != null && feedback.isNotEmpty
              ? feedback
              : 'Belum Ada Rating Dan Feedback Yang Diberikan!',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
