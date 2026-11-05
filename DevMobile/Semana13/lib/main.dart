import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(home: FotoTela()));
}

class FotoTela extends StatefulWidget {
  const FotoTela({super.key});

  @override
  State<FotoTela> createState() => _FotoTelaState();
}

class _FotoTelaState extends State<FotoTela> {
  File? _foto;

  Future<void> _tirarFoto() async {
    final imagem = await ImagePicker().pickImage(source: ImageSource.camera);
    if (imagem != null) {
      setState(() => _foto = File(imagem.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tirar foto')),
      body: Center(
        child: _foto == null
            ? const Text('Nenhuma foto tirada.')
            : Image.file(_foto!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tirarFoto,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
