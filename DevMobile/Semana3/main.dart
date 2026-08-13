import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const NovaApp());
}

class NovaApp extends StatefulWidget {
  const NovaApp({super.key});

  @override
  State<NovaApp> createState() => _NovaAppState();
}

class _NovaAppState extends State<NovaApp> {
  String resultado = 'Escolha um número de 1 a 5!';

  void verificarNumero(int palpite) {
    int numeroSorteado = Random().nextInt(5) + 1;

    setState(() {
      if (palpite == numeroSorteado) {
        resultado = 'Você ACERTOU! O número era $numeroSorteado.';
      } else {
        resultado = 'Você ERROU! O número era $numeroSorteado.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                resultado,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => verificarNumero(1),
                    child: const Text('1'),
                  ),
                  TextButton(
                    onPressed: () => verificarNumero(2),
                    child: const Text('2'),
                  ),
                  TextButton(
                    onPressed: () => verificarNumero(3),
                    child: const Text('3'),
                  ),
                  TextButton(
                    onPressed: () => verificarNumero(4),
                    child: const Text('4'),
                  ),
                  TextButton(
                    onPressed: () => verificarNumero(5),
                    child: const Text('5'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
