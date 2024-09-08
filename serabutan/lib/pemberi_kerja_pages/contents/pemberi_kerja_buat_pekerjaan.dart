import 'package:flutter/material.dart';
import 'package:serabutan/pemberi_kerja_pages/contents/pemberi_kerja_detail_pekerjaan_dipublish.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:serabutan/config.dart';

class PemberiKerjaBuatPekerjaanPage extends StatefulWidget {
  @override
  _PemberiKerjaBuatPekerjaanPageState createState() =>
      _PemberiKerjaBuatPekerjaanPageState();
}

class _PemberiKerjaBuatPekerjaanPageState
    extends State<PemberiKerjaBuatPekerjaanPage> {
  late Future<List<dynamic>> _createdJobsFuture;

  @override
  void initState() {
    super.initState();
    _createdJobsFuture = fetchCreatedJobs();
  }

  Future<int?> getPemberiKerjaId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_pemberi_kerja');
  }

  Future<List<dynamic>> fetchCreatedJobs() async {
    int? idPemberiKerja = await getPemberiKerjaId();
    if (idPemberiKerja == null) {
      return [];
    }

    final response = await http.get(Uri.parse(Config.baseUrl +
        'ambil_pekerjaan.php?id_pemberi_kerja=$idPemberiKerja'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('gagal load pekerjaan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'BUAT PEKERJAAN',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/tambah_pekerjaan');
            },
            child: Text('Buat Pekerjaan'),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _createdJobsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(
                    'Belum Ada Pekerjaan dibuat!.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final job = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(
                            Config.fotoPekerjaanUrl + job['foto_pekerjaan'],
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                          title: Text(
                            job['nama_pekerjaan'],
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                              'Jumlah pengajuan: ${job['jumlah_pengajuan']}\nStatus: ${job['status_pekerjaan']}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPekerjaanPage(
                                  idPekerjaan: (job['id_pekerjaan']),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
