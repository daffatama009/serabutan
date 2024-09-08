import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'dart:html' as html;

// import 'package:serabutan/pencari_kerja_pages/contents/pencari_kerja_pekerjaanku.dart';
import 'package:serabutan/pencari_kerja_pages/pencari_kerja_homepage.dart'; // for web support

class BuktiPengajuanPencariKerjaPage extends StatefulWidget {
  final int idPekerjaan;
  final int idPengajuan;

  const BuktiPengajuanPencariKerjaPage(
      {super.key, required this.idPekerjaan, required this.idPengajuan});

  @override
  State<BuktiPengajuanPencariKerjaPage> createState() =>
      _BuktiPengajuanPencariKerjaPageState();
}

class _BuktiPengajuanPencariKerjaPageState
    extends State<BuktiPengajuanPencariKerjaPage> {
  io.File? _selectedImage;
  html.File? _webImage;
  String? _imageUrl; // To display temporary image URL
  String _statusPengajuan = 'selesai'; // or another status if applicable

  Future<void> _pickImage() async {
    if (kIsWeb) {
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((event) {
        final files = uploadInput.files;
        if (files!.isNotEmpty) {
          _webImage = files.first;
          setState(() {
            // Displaying temporary image for web
            _imageUrl = html.Url.createObjectUrlFromBlob(_webImage!);
          });
        }
      });
    } else {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = io.File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _uploadBukti() async {
    try {
      var request = http.MultipartRequest('POST',
          Uri.parse(Config.baseUrl + "bukti_pengajuan_pencari_kerja.php"));
      request.fields['id_pekerjaan'] = widget.idPekerjaan.toString();
      request.fields['id_pengajuan'] = widget.idPengajuan.toString();
      request.fields['tanggal_selesai'] = DateTime.now().toIso8601String();
      request.fields['waktu_selesai'] = DateTime.now().toIso8601String();
      request.fields['status_pengajuan'] = _statusPengajuan;

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'foto_bukti', _selectedImage!.path));
      } else if (_webImage != null) {
        var reader = html.FileReader();
        reader.readAsDataUrl(_webImage!);
        await reader.onLoadEnd.first;
        var data = reader.result as String;
        var bytes = base64Decode(data.split(",").last);
        request.files.add(http.MultipartFile.fromBytes('foto_bukti', bytes,
            filename: _webImage!.name));
      }

      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (responseBody.statusCode == 200) {
        try {
          final responseJson = jsonDecode(responseBody.body);
          if (responseJson['status'] == 'success') {
            Fluttertoast.showToast(msg: 'Bukti berhasil diunggah');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PencariKerjaHomepage(),
              ),
            );
          } else {
            Fluttertoast.showToast(
                msg: 'Gagal mengunggah bukti: ${responseJson['message']}');
          }
        } catch (e) {
          Fluttertoast.showToast(
              msg: 'Gagal mengunggah bukti: Format respons tidak valid');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Gagal mengunggah bukti: Server error dengan kode ${responseBody.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal mengunggah bukti: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Bukti Pengajuan Pencari Kerja'),
          backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Unggah Bukti Pengajuan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _webImage != null
                  ? Image.network(
                      _imageUrl!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                  : _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        )
                      : Container(),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pilih Foto'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadBukti,
                child: Text('Unggah Bukti'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
