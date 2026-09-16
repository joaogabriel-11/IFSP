import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Tabuada(),
  ));
}

class Tabuada extends StatefulWidget {
  const Tabuada({super.key});

  @override
  State<Tabuada> createState() => _TabuadaState();
}

class _TabuadaState extends State<Tabuada> {
  int numero1 = 7;
  int numero2 = 8;

  bool? respostaCorreta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino de Tabuada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '$numero1 x $numero2 = ?',
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite a resposta',
              ),
              onChanged: (valor) {
                setState(() {
                  int? resposta = int.tryParse(valor);

                  if (valor.isEmpty) {
                    respostaCorreta = null;
                  } else {
                    respostaCorreta = resposta == numero1 * numero2;
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            if (respostaCorreta != null)
              Icon(
                respostaCorreta! ? Icons.check_circle : Icons.cancel,
                size: 50,
                color: respostaCorreta! ? Colors.green : Colors.red,
              ),
          ],
        ),
      ),
    );
  }
}
