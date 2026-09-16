import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Galeria(),
    debugShowCheckedModeBanner: false,
  ));
}

class Galeria extends StatefulWidget {
  const Galeria({super.key});

  @override
  State<Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<Galeria> {
  int imagemAtual = 0;

  List<String> imagens = [
    'https://upload.wikimedia.org/wikipedia/commons/e/e3/Facade_de_la_Cath%C3%A9drale_de_Rouen_au_matin.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/1/13/Ismail_Pacha.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/7/75/-0035_Altes_Museum_Portrait_Kleopatra_VII_anagoria.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/9/95/Suvarnabhumi_Airport_inside.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/d/d5/Old_English_Sheep_Dog.JPG',
  ];

  List<bool> gostei = [
    false,
    false,
    false,
    false,
    false,
  ];

  void proximaImagem() {
    setState(() {
      if (imagemAtual < imagens.length - 1) {
        imagemAtual++;
      } else {
        imagemAtual = 0;
      }
    });
  }

  void mudarGostei() {
    setState(() {
      gostei[imagemAtual] = !gostei[imagemAtual];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imagens da Wikipedia'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imagens[imagemAtual],
              width: 200,
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: mudarGostei,
              child: Icon(
                gostei[imagemAtual]
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 50,
                color: gostei[imagemAtual]
                    ? Colors.red
                    : Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Imagem ${imagemAtual + 1} de ${imagens.length}',
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: proximaImagem,
              child: const Text('Próxima imagem'),
            ),
          ],
        ),
      ),
    );
  }
}