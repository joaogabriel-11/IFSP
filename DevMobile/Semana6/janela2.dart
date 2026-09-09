import 'package:flutter/material.dart';
import 'package:flutter_application_2/pergunta.dart';
import 'package:flutter_application_2/questoes.dart';

class Janela2 extends StatefulWidget {
  const Janela2(
    this.volta, {
    super.key,
  });

  final Function() volta;

  @override
  State<Janela2> createState() => _Janela2State();
}

class _Janela2State extends State<Janela2> {
  int indicePergunta = 0;

  void responder() {
    if (indicePergunta < questoes.length - 1) {
      setState(() {
        indicePergunta++;
      });
    } else {
      widget.volta();
    }
  }

  @override
  Widget build(BuildContext context) {
    Pergunta perguntaAtual = questoes[indicePergunta];

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/imagens/palhaco_ouve.png',
              ),
            ),
          ),
          Text(perguntaAtual.texto),
          const SizedBox(
            height: 10,
          ),
          ...perguntaAtual.embaralha().map((resposta) {
            return ElevatedButton(
              onPressed: responder,
              child: Text(resposta),
            );
          }),
        ],
      ),
    );
  }
}
