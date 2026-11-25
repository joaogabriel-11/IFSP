import 'dart:convert';
import 'package:http/http.dart' as http;

// Endereço da API (troque conforme onde o app roda):
// - Emulador Android: http://10.0.2.2/atividades_api
// - Chrome/Windows:   http://localhost/atividades_api
// - Celular físico:   http://IP_DO_PC/atividades_api (ex.: 192.168.0.10)
const String baseUrl = 'http://localhost/atividades_api';

class Api {
  // Busca as atividades de um mês/ano. Retorna uma lista de mapas (JSON).
  static Future<List<dynamic>> listar(int mes, int ano) async {
    final resposta =
        await http.get(Uri.parse('$baseUrl/listar.php?mes=$mes&ano=$ano'));
    return jsonDecode(resposta.body);
  }

  // Envia uma atividade para salvar. Retorna true se deu certo.
  static Future<bool> salvar(String descricao, String data) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/salvar.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'descricao': descricao, 'data': data}),
    );
    return jsonDecode(resposta.body)['sucesso'] == true;
  }
}
