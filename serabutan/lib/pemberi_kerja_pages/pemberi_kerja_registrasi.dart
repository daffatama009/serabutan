import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import 'dart:html' as html; // for web support

class PemberiKerjaRegistrasi extends StatefulWidget {
  @override
  _PemberiKerjaRegistrasiState createState() => _PemberiKerjaRegistrasiState();
}

class _PemberiKerjaRegistrasiState extends State<PemberiKerjaRegistrasi> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();

  io.File? _selectedImage;
  html.File? _webImage;
  String? _imageUrl; // To display temporary image URL

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

  bool _isValidUsername(String value) {
    // Validate username (letters and numbers only)
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(value);
  }

  bool _isValidPassword(String value) {
    // Validate password (letters and numbers only)
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(value);
  }

  Future<void> _registrasiPemberiKerja() async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse(Config.registrasiPemberiKerjaUrl));
      request.fields['username'] = _usernameController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['nama'] = _namaController.text;
      request.fields['alamat'] = _alamatController.text;
      request.fields['no_telepon'] = _noTeleponController.text;

      if (_selectedImage != null) {
        request.files.add(
            await http.MultipartFile.fromPath('foto', _selectedImage!.path));
      } else if (_webImage != null) {
        var reader = html.FileReader();
        reader.readAsDataUrl(_webImage!);
        await reader.onLoadEnd.first;
        var data = reader.result as String;
        var bytes = base64Decode(data.split(",").last);
        request.files.add(http.MultipartFile.fromBytes('foto', bytes,
            filename: _webImage!.name));
      }

      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (responseBody.statusCode == 200) {
        try {
          final responseJson = jsonDecode(responseBody.body);
          if (responseJson['status'] == 'success') {
            Fluttertoast.showToast(msg: 'Registrasi berhasil');
            _clearFields();
          } else {
            Fluttertoast.showToast(
                msg: 'Registrasi gagal: ${responseJson['message']}');
          }
        } catch (e) {
          Fluttertoast.showToast(
              msg: 'Registrasi gagal: Format respons tidak valid');
        }
      } else {
        Fluttertoast.showToast(
            msg:
                'Registrasi gagal: Server error dengan kode ${responseBody.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Registrasi gagal: $e');
    }
  }

  void _clearFields() {
    _usernameController.clear();
    _passwordController.clear();
    _namaController.clear();
    _alamatController.clear();
    _noTeleponController.clear();
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrasi Pemberi Kerja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registrasi Pemberi Kerja',
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
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Validate and restrict input to alphanumeric characters
                  if (!_isValidUsername(value)) {
                    _usernameController.text = _usernameController.text
                        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                    _usernameController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _usernameController.text.length),
                    );
                    Fluttertoast.showToast(
                        msg: 'Hanya huruf dan angka diizinkan untuk username.');
                  }
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  // Validate and restrict input to alphanumeric characters
                  if (!_isValidPassword(value)) {
                    _passwordController.text = _passwordController.text
                        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                    _passwordController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _passwordController.text.length),
                    );
                    Fluttertoast.showToast(
                        msg: 'Hanya huruf dan angka diizinkan untuk password.');
                  }
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _noTeleponController,
                decoration: InputDecoration(
                  labelText: 'No Telepon',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _registrasiPemberiKerja,
                child: Text('Registrasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
