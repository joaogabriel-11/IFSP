import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Emulador Android: 10.0.2.2 | Celular: IP do PC | Chrome: localhost
const String baseUrl = 'http://10.0.2.2/aula13';

void main() {
  runApp(const MaterialApp(home: EnviarTela()));
}

// ---------- Tela 1: envia um texto ----------
class EnviarTela extends StatefulWidget {
  const EnviarTela({super.key});

  @override
  State<EnviarTela> createState() => _EnviarTelaState();
}

class _EnviarTelaState extends State<EnviarTela> {
  final _controller = TextEditingController();
  String _mensagem = '';

  Future<void> _enviar() async {
    final url = Uri.parse('$baseUrl/salva.php')
        .replace(queryParameters: {'txt': _controller.text});
    final resposta = await http.get(url);
    setState(() => _mensagem = resposta.body);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar texto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _controller),
            ElevatedButton(onPressed: _enviar, child: const Text('Enviar')),
            Text(_mensagem),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VerTextosTela()),
              ),
              child: const Text('Ver textos salvos'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Tela 2: mostra os textos, um por vez ----------
class VerTextosTela extends StatefulWidget {
  const VerTextosTela({super.key});

  @override
  State<VerTextosTela> createState() => _VerTextosTelaState();
}

class _VerTextosTelaState extends State<VerTextosTela> {
  int _id = 0;
  String _texto = '';

  @override
  void initState() {
    super.initState();
    _proximo();
  }

  Future<void> _proximo() async {
    final url = Uri.parse('$baseUrl/busca.php')
        .replace(queryParameters: {'id': '$_id'});
    final resposta = await http.get(url);
    final dados = jsonDecode(resposta.body);

    setState(() {
      if (dados['erro'] != null) {
        _texto = 'Não há mais textos.';
        _id = 0; // próximo clique volta ao primeiro
      } else {
        _id = dados['id'];
        _texto = dados['texto'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Textos salvos')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_texto, style: const TextStyle(fontSize: 24)),
            ElevatedButton(onPressed: _proximo, child: const Text('Próximo')),
          ],
        ),
      ),
    );
  }
}
