import 'package:flutter/material.dart';
import 'package:flutter_application_2/janela1.dart';
import 'package:flutter_application_2/janela2.dart';

void main() {
  runApp(
    Controle(),
  );
}

class Controle extends StatefulWidget {
  const Controle({super.key});

  @override
  State<Controle> createState() => _ControleState();
}

class _ControleState extends State<Controle> {
  var janela = 'um';

  void muda() {
    setState(() {
      janela = 'dois';
    });
  }

  void volta() {
    setState(() {
      janela = 'um';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget atual = Janela1(muda);

    if (janela == 'um') {
      atual = Janela1(muda);
    } else {
      atual = Janela2(volta);
    }

    return MaterialApp(
      home: atual,
    );
  }
}
