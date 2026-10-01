import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/produto.dart';

Future<Produto> buscarProduto() async {
  final resposta = await http.get(
    Uri.parse('https://dummyjson.com/products/1'),
    headers: {'Accept': 'application/json'},
  );

  if (resposta.statusCode == 200) {
    final json = jsonDecode(resposta.body) as Map<String, dynamic>;
    return Produto.fromJson(json);
  }

  throw Exception('Falha ao carregar produto.');
}
