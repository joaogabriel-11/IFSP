import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost/trufas';

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> dados,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    print('Enviando requisição para: $url');
    print('Dados: $dados');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dados),
    );

    print('Status HTTP: ${response.statusCode}');
    print('Resposta PHP: ${response.body}');

    final resultado = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return resultado;
    }

    throw Exception(
      resultado['erro'] ?? 'Erro na requisição',
    );
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
    );

    final resultado = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return resultado;
    }

    throw Exception(
      resultado['erro'] ?? 'Erro na requisição',
    );
  }
}
