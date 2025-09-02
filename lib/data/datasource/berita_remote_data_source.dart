import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/berita_model.dart';

class BeritaRemoteDataSource {
  final String baseUrl = 'https://awdiv2.kalbarprov.go.id/api/all_kalbar_article';

  Future<List<BeritaModel>> fetchBerita([String keyword = '']) async {
    final uri = Uri.parse('$baseUrl?search=$keyword');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final data = jsonBody['data'] as List;
      

      return data.map((json) => BeritaModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat berita');
    }
  }

//   Future<void> cekJumlahBerita() async {
//   final uri = Uri.parse(baseUrl);

//   final response = await http.get(uri);

//   if (response.statusCode == 200) {
//     final jsonBody = json.decode(response.body);
//     final List data = jsonBody['data'];
//     print('Jumlah berita: ${data.length}');
//   } else {
//     print('Gagal mengambil data, status: ${response.statusCode}');
//   }
// }

}
