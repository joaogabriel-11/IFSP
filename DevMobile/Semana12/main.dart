import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MultiplicacaoApp());
}

class MultiplicacaoApp extends StatelessWidget {
  const MultiplicacaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabuada',
      debugShowCheckedModeBanner: false,
      home: const MultiplicacaoPage(),
    );
  }
}

class MultiplicacaoPage extends StatefulWidget {
  const MultiplicacaoPage({super.key});

  @override
  State<MultiplicacaoPage> createState() => _MultiplicacaoPageState();
}

class _MultiplicacaoPageState extends State<MultiplicacaoPage> {
  int fator = 1;
  int multiplicador = 1;
  int acertosNoFator = 0;
  String resposta = '';

  int? fatorAnterior;
  int? multiplicadorAnterior;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fator = prefs.getInt('fator') ?? 1;
      multiplicador = prefs.getInt('multiplicador') ?? 1;
      acertosNoFator = prefs.getInt('acertos') ?? 0;
      carregando = false;
    });
  }

  Future<void> salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fator', fator);
    await prefs.setInt('multiplicador', multiplicador);
    await prefs.setInt('acertos', acertosNoFator);
  }

  void digitar(String n) {
    if (resposta.length < 3) {
      setState(() => resposta += n);
    }
  }

  void apagar() {
    if (resposta.isNotEmpty) {
      setState(() => resposta = resposta.substring(0, resposta.length - 1));
    }
  }

  void limpar() {
    setState(() => resposta = '');
  }

  void verificar() {
    if (resposta.isEmpty) return;

    final valor = int.tryParse(resposta);
    if (valor == null) return;

    if (valor == fator * multiplicador) {
      // Acertou
      setState(() {
        acertosNoFator++;
        resposta = '';
        if (multiplicador < 10) {
          multiplicador++;
        } else {
          proximoFator();
        }
      });
      salvar();
    } else {
      // Errou
      fatorAnterior = fator;
      multiplicadorAnterior = multiplicador;

      setState(() {
        resposta = '';
        if (multiplicador < 10) {
          multiplicador++;
        } else {
          proximoFator();
        }
      });
      salvar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Errou, clique aqui para continuar'),
          action: SnackBarAction(
            label: 'Continuar',
            onPressed: () {
              setState(() {
                fator = fatorAnterior!;
                multiplicador = multiplicadorAnterior!;
              });
              salvar();
            },
          ),
        ),
      );
    }
  }

  void proximoFator() {
    if (fator < 10) {
      fator++;
    } else {
      fator = 1;
    }
    multiplicador = 1;
    acertosNoFator = 0;
  }

  Widget botao(String texto, VoidCallback onTap, {Color? cor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: cor,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(texto, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabuada'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progresso
            Text('Fator $fator  •  $acertosNoFator/10'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: acertosNoFator / 10),
            const SizedBox(height: 30),

            // Operação
            Text(
              '$fator × $multiplicador = ?',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Resposta
            Text(
              resposta.isEmpty ? '?' : resposta,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 24),

            // Teclado
            Row(children: [
              botao('1', () => digitar('1')),
              botao('2', () => digitar('2')),
              botao('3', () => digitar('3')),
            ]),
            Row(children: [
              botao('4', () => digitar('4')),
              botao('5', () => digitar('5')),
              botao('6', () => digitar('6')),
            ]),
            Row(children: [
              botao('7', () => digitar('7')),
              botao('8', () => digitar('8')),
              botao('9', () => digitar('9')),
            ]),
            Row(children: [
              botao('C', limpar, cor: Colors.red[300]),
              botao('0', () => digitar('0')),
              botao('⌫', apagar, cor: Colors.orange[300]),
            ]),

            const SizedBox(height: 16),

            // Verificar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verificar,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Verificar', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
