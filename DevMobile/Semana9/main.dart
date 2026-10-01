import 'package:flutter/material.dart';

import 'models/produto.dart';
import 'services/produto_service.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Produto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TelaProduto(),
    );
  }
}

class TelaProduto extends StatefulWidget {
  const TelaProduto({super.key});

  @override
  State<TelaProduto> createState() => _TelaProdutoState();
}

class _TelaProdutoState extends State<TelaProduto> {
  late Future<Produto> produtoFuturo;

  @override
  void initState() {
    super.initState();
    produtoFuturo = buscarProduto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<Produto>(
          future: produtoFuturo,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('Nenhum produto encontrado.'),
              );
            }

            final produto = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.titulo,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Text('Preço: R\$ ${produto.preco.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                Text('Categoria: ${produto.categoria}'),
                const SizedBox(height: 10),
                Text('Avaliação: ${produto.avaliacao}'),
              ],
            );
          },
        ),
      ),
    );
  }
}
