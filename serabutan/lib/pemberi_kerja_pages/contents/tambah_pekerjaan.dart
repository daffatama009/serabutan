import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:serabutan/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TambahPekerjaanPage extends StatefulWidget {
  @override
  _TambahPekerjaanPageState createState() => _TambahPekerjaanPageState();
}

class _TambahPekerjaanPageState extends State<TambahPekerjaanPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaPekerjaanController = TextEditingController();
  final _bayaranController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _waktuController = TextEditingController();
  final _alamatController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedCategory;
  io.File? _selectedImage;
  html.File? _webImage;
  String? _imageUrl;

  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(Config.ambilKategoriUrl));
      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        setState(() {
          _categories =
              List<Map<String, dynamic>>.from(responseJson['categories']);
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

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

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _waktuController.text = picked.format(context);
      });
    }
  }

  Future<int?> getPemberiKerjaId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_pemberi_kerja');
  }

  void _clearFields() {
    _namaPekerjaanController.clear();
    _bayaranController.clear();
    _tanggalController.clear();
    _alamatController.clear();
    _waktuController.clear();
    _deskripsiController.clear();
    _categories.clear();
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _imageUrl = null;
    });
  }

  Future<void> _buatPekerjaan() async {
    if (_formKey.currentState!.validate()) {
      int? idPemberiKerja = await getPemberiKerjaId();
      if (idPemberiKerja == null) {
        print('id_pemberi_kerja tidak ditemukan');
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Config.tambahPekerjaanUrl),
      );
      request.fields['nama_pekerjaan'] = _namaPekerjaanController.text;
      request.fields['bayaran'] = _bayaranController.text;
      request.fields['tanggal'] = _tanggalController.text;
      request.fields['waktu'] = _waktuController.text;
      request.fields['alamat'] = _alamatController.text;
      request.fields['deskripsi'] = _deskripsiController.text;
      request.fields['id_kategori'] = _categories
          .firstWhere(
              (cat) => cat['nama_kategori'] == _selectedCategory)['id_kategori']
          .toString();
      request.fields['id_pemberi_kerja'] = idPemberiKerja.toString();

      if (_selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'foto',
          _selectedImage!.path,
        ));
      } else if (_webImage != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webImage!);
        await reader.onLoad.first;

        final bytes = reader.result as Uint8List;
        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          bytes,
          filename: _webImage!.name,
        ));
      }

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: 'Pekerjaan berhasil dibuat');
          _clearFields();
          print('Response body: ${await response.stream.bytesToString()}');
        } else {
          print('Failed to add job: ${response.statusCode}');
          print('Response body: ${await response.stream.bytesToString()}');
        }
      } catch (e) {
        print('Error adding job: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Pekerjaan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaPekerjaanController,
                decoration: InputDecoration(labelText: 'Nama Pekerjaan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama pekerjaan wajib diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bayaranController,
                decoration: InputDecoration(labelText: 'Bayaran'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bayaran wajib diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tanggalController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal wajib diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _waktuController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Waktu',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.access_time),
                    onPressed: _selectTime,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Waktu wajib diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat wajib diisi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem<String>(
                          value: category['nama_kategori'],
                          child: Text(category['nama_kategori']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Kategori'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori wajib dipilih';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              GestureDetector(
                onTap: _pickImage,
                child: _imageUrl != null
                    ? kIsWeb
                        ? Image.network(_imageUrl!)
                        : Image.file(_selectedImage!)
                    : Container(
                        width: double.infinity,
                        height: 150.0,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.grey[800],
                        ),
                      ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _buatPekerjaan,
                child: Text('Buat Pekerjaan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
