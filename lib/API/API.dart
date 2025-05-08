import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);

    print('Data pertama:');
    print('ID: ${data[0]['id']}');
    print('Title: ${data[0]['title']}');
    print('Body: ${data[0]['body']}');
  } else {
    print('Gagal mengambil data. Status code: ${response.statusCode}');
  }
}
