import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:serabutan/config.dart';
import 'package:serabutan/pencari_kerja_pages/contents/pencari_kerja_detail_pekerjaan.dart';

class PencariKerjaDaftarPekerjaanPage extends StatefulWidget {
  const PencariKerjaDaftarPekerjaanPage({super.key});

  @override
  State<PencariKerjaDaftarPekerjaanPage> createState() =>
      _PencariKerjaDaftarPekerjaanPageState();
}

class _PencariKerjaDaftarPekerjaanPageState
    extends State<PencariKerjaDaftarPekerjaanPage> {
  late Future<List<dynamic>> _jobListFuture;

  @override
  void initState() {
    super.initState();
    _jobListFuture = fetchJobList();
  }

  Future<List<dynamic>> fetchJobList() async {
    final response = await http
        .get(Uri.parse(Config.baseUrl + 'ambil_daftar_pekerjaan.php'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load job list');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _jobListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Tidak Ada Pekerjaan'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final job = snapshot.data![index];
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PencariKerjaDetailPekerjaanPage(
                            idPekerjaan: int.parse(job['id_pekerjaan']),
                          ),
                        ),
                      );
                    },
                    leading: Image.network(
                      Config.baseUrl +
                          'uploads/foto_pekerjaan/' +
                          job['foto_pekerjaan'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                    title: Text(job['nama_pekerjaan']),
                    subtitle: Text('Bayaran: ${job['bayaran']}'),
                    // trailing: ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) =>
                    //             PencariKerjaDetailPekerjaanPage(
                    //           idPekerjaan: int.parse(job['id_pekerjaan']),
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   child: Text('Lihat'),
                    // ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
