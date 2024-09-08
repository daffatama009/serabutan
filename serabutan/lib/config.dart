class Config {
  static const String baseUrl = 'http://192.168.1.9/api_serabutan/';
  static const String registrasiPencariKerjaUrl =
      baseUrl + 'registrasi_pencari_kerja.php';
  static const String registrasiPemberiKerjaUrl =
      baseUrl + 'registrasi_pemberi_kerja.php';
  static const String loginPencariKerjaUrl =
      baseUrl + 'login_pencari_kerja.php';
  static const String loginPemberiKerjaUrl =
      baseUrl + 'login_pemberi_kerja.php';
  static const String ambilDataPemberiKerjaUrl =
      baseUrl + 'ambil_data_pemberi_kerja.php';
  static const String ambilDataPencariKerjaUrl =
      baseUrl + 'ambil_data_pencari_kerja.php';
  static const String logoutUrl = baseUrl + 'logout.php';
  static const String fotoProfilePencariKerjaUrl =
      baseUrl + 'uploads/pencari_kerja_profile_images/';
  static const String fotoProfilePemberiKerjaUrl =
      baseUrl + 'uploads/pemberi_kerja_profile_images/';
  static const String fotoPekerjaanUrl = baseUrl + 'uploads/foto_pekerjaan/';
  static const String fotoBuktiPekerjaanUrl =
      baseUrl + 'uploads/foto_bukti_selesai/';
  static const String tambahPekerjaanUrl = baseUrl + 'simpan_pekerjaan.php';
  static const String ambilKategoriUrl = baseUrl + 'ambil_kategori.php';
  static const String ambilPekerjaanUrl = baseUrl + 'ambil_pekerjaan.php';
}
