import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:serabutan/pemberi_kerja_pages/contents/pemberi_kerja_bukti_pekerjaan_selesai.dart';

class PemberiKerjaDetailPekerjaanBerjalanPage extends StatefulWidget {
  final int idPekerjaan;
  const PemberiKerjaDetailPekerjaanBerjalanPage(
      {super.key, required this.idPekerjaan});

  @override
  State<PemberiKerjaDetailPekerjaanBerjalanPage> createState() =>
      _PemberiKerjaDetailPekerjaanBerjalanPageState();
}

class _PemberiKerjaDetailPekerjaanBerjalanPageState
    extends State<PemberiKerjaDetailPekerjaanBerjalanPage> {
  String namapekerjaan = "";
  String fotopekerjaan = "";
  List<dynamic> _pencariKerjaList = [];

  @override
  void initState() {
    super.initState();
    _fetchDetailPekerjaan();
  }

  Future<void> _fetchDetailPekerjaan() async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl +
            'ambil_detail_pekerjaan_berjalan_pemberi_kerja.php'),
        body: {
          'id_pekerjaan': widget.idPekerjaan.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          setState(() {
            namapekerjaan = responseJson['data'][0]['nama_pekerjaan'];
            fotopekerjaan = responseJson['data'][0]['foto_pekerjaan'];
            _pencariKerjaList = responseJson['data'];
          });
        } else {
          Fluttertoast.showToast(
              msg: 'Gagal memuat detail pekerjaan: ${responseJson['message']}');
          print(responseJson);
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal memuat detail pekerjaan: Server error dengan kode ${response.statusCode}');
        print(response.statusCode);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memuat detail pekerjaan: $e');
      print(e);
    }
  }

  Future<void> _SelesaikanPekerjaan() async {
    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + 'selesaikan_pekerjaan.php'),
        body: {
          'id_pekerjaan': widget.idPekerjaan.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        if (responseJson['status'] == 'success') {
          Fluttertoast.showToast(msg: 'Pekerjaan selesai');
          // Tambahkan aksi yang diperlukan setelah pekerjaan berjalan
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
          namapekerjaan,
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0, // Remove app bar shadow
      ),
      body: namapekerjaan.isNotEmpty
          ? Column(
              children: [
                // Text(
                //   namapekerjaan,
                //   style: TextStyle(fontSize: 20, color: Colors.black),
                // ),
                SizedBox(
                  height: 20,
                ),
                Image.network(
                  Config.fotoPekerjaanUrl + fotopekerjaan,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _pencariKerjaList.length,
                    itemBuilder: (context, index) {
                      var pencariKerja = _pencariKerjaList[index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(8), // Add rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                Config.fotoProfilePencariKerjaUrl +
                                    pencariKerja['foto']),
                          ),
                          title: Text(
                            pencariKerja['nama_pencari_kerja'],
                            style: TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            'Status: ${pencariKerja['status_pengajuan']}',
                            style: TextStyle(color: Colors.black),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PemberiKerjaBuktiPekerjaanSelesaiPage(
                                  idPekerjaan: widget.idPekerjaan,
                                  idPencariKerja:
                                      pencariKerja['id_pencari_kerja'],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _SelesaikanPekerjaan,
                  child: Text('Selesaikan Pekerjaan'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Add rounded corners
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
