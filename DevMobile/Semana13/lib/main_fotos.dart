import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Emulador Android: 10.0.2.2 | Celular: IP do PC | Chrome: localhost
const String baseUrl = 'http://10.0.2.2/aula13';

void main() {
  runApp(const MaterialApp(home: EnviarFotoTela()));
}

// ---------- Tela 1: tira a foto e envia com uma descrição ----------
class EnviarFotoTela extends StatefulWidget {
  const EnviarFotoTela({super.key});

  @override
  State<EnviarFotoTela> createState() => _EnviarFotoTelaState();
}

class _EnviarFotoTelaState extends State<EnviarFotoTela> {
  final _controller = TextEditingController();
  File? _foto;
  String _mensagem = '';

  Future<void> _tirarFoto() async {
    final imagem = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    if (imagem != null) {
      setState(() => _foto = File(imagem.path));
    }
  }

  Future<void> _enviar() async {
    final pedido =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/salva_foto.php'));
    pedido.fields['desc'] = _controller.text;
    pedido.files.add(await http.MultipartFile.fromPath('foto', _foto!.path));
    final resposta = await pedido.send();
    final texto = await resposta.stream.bytesToString();
    setState(() {
      _mensagem = texto;
      _foto = null;
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar foto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_foto != null) Image.file(_foto!, height: 250),
              ElevatedButton(
                  onPressed: _tirarFoto, child: const Text('Tirar foto')),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              ElevatedButton(
                onPressed: _foto == null ? null : _enviar,
                child: const Text('Enviar'),
              ),
              Text(_mensagem),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VerFotosTela()),
                ),
                child: const Text('Ver fotos salvas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Tela 2: mostra as fotos, uma por vez ----------
class VerFotosTela extends StatefulWidget {
  const VerFotosTela({super.key});

  @override
  State<VerFotosTela> createState() => _VerFotosTelaState();
}

class _VerFotosTelaState extends State<VerFotosTela> {
  int _id = 0;
  String _arquivo = '';
  String _descricao = '';

  @override
  void initState() {
    super.initState();
    _proximo();
  }

  Future<void> _proximo() async {
    final url = Uri.parse('$baseUrl/busca_foto.php')
        .replace(queryParameters: {'id': '$_id'});
    final resposta = await http.get(url);
    final dados = jsonDecode(resposta.body);

    setState(() {
      if (dados['erro'] != null) {
        _arquivo = '';
        _descricao = 'Não há mais fotos.';
        _id = 0; // próximo clique volta à primeira
      } else {
        _id = dados['id'];
        _arquivo = dados['arquivo'];
        _descricao = dados['descricao'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fotos salvas')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_arquivo != '')
              Image.network('$baseUrl/fotos/$_arquivo', height: 300),
            Text(_descricao, style: const TextStyle(fontSize: 24)),
            ElevatedButton(onPressed: _proximo, child: const Text('Próxima')),
          ],
        ),
      ),
    );
  }
}
