import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:serabutan/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PemberiKerjaBeriRatingPage extends StatefulWidget {
  final int idPencariKerja;
  final int idPekerjaan;

  const PemberiKerjaBeriRatingPage({
    super.key,
    required this.idPencariKerja,
    required this.idPekerjaan,
  });

  @override
  State<PemberiKerjaBeriRatingPage> createState() =>
      _PemberiKerjaBeriRatingPageState();
}

class _PemberiKerjaBeriRatingPageState
    extends State<PemberiKerjaBeriRatingPage> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isRatingExists = false;
  int? _idPemberiKerja;

  @override
  void initState() {
    super.initState();
    _loadPemberiKerjaId();
  }

  Future<void> _loadPemberiKerjaId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idPemberiKerja = prefs.getInt('id_pemberi_kerja');
    });
    _checkExistingRating();
  }

  Future<void> _checkExistingRating() async {
    if (_idPemberiKerja == null) return;

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl +
            'cek_rating_pemberi_kerja.php'), // Endpoint to check if rating exists
        body: {
          'id_pemberi_kerja': _idPemberiKerja.toString(),
          'id_pencari_kerja': widget.idPencariKerja.toString(),
          'id_pekerjaan': widget.idPekerjaan.toString(),
        },
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200 && responseJson['status'] == 'success') {
        if (responseJson['rating_exists']) {
          setState(() {
            _rating = responseJson['rating'];
            _feedbackController.text = responseJson['feedback'];
            _isRatingExists = true;
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to check rating: ${responseJson['message']}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      Fluttertoast.showToast(msg: 'Please provide a rating');
      return;
    }

    if (_idPemberiKerja == null) {
      Fluttertoast.showToast(msg: 'User ID not found');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(Config.baseUrl + 'simpan_rating_pemberi_kerja.php'),
        body: {
          'id_pemberi_kerja': _idPemberiKerja.toString(),
          'id_pekerjaan': widget.idPekerjaan.toString(),
          'id_pencari_kerja': widget.idPencariKerja.toString(),
          'rating': _rating.toString(),
          'feedback': _feedbackController.text,
        },
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseJson['status'] == 'success') {
          Fluttertoast.showToast(msg: 'Rating submitted successfully');
          Navigator.pop(context);
        } else {
          Fluttertoast.showToast(
              msg: 'Failed to submit rating: ${responseJson['message']}');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beri Rating'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Rate the worker:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: _isRatingExists
                      ? null
                      : () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                );
              }),
            ),
            TextField(
              controller: _feedbackController,
              decoration: InputDecoration(labelText: 'Feedback'),
              readOnly: _isRatingExists,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRatingExists ? null : _submitRating,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
