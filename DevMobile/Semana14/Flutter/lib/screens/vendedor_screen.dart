import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class VendedorScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const VendedorScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<VendedorScreen> createState() => _VendedorScreenState();
}

class _VendedorScreenState extends State<VendedorScreen> {
  List<Map<String, dynamic>> producoes = [];
  final Map<int, TextEditingController> controllers = {};

  double comissao = 0;
  bool carregando = true;
  bool comprando = false;

  @override
  void initState() {
    super.initState();
    carregarProducoes();
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> carregarProducoes() async {
    setState(() => carregando = true);

    try {
      final resultado = await ApiService.get('vendas/producoes.php');

      if (!mounted) return;

      for (final c in controllers.values) {
        c.dispose();
      }
      controllers.clear();

      final lista = (resultado['producoes'] as List)
          .map((p) => Map<String, dynamic>.from(p))
          .toList();

      for (final p in lista) {
        controllers[p['id']] = TextEditingController();
      }

      setState(() {
        producoes = lista;
        comissao = double.parse(resultado['comissao'].toString());
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => carregando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  int quantidadeDe(Map<String, dynamic> producao) {
    return int.tryParse(controllers[producao['id']]?.text ?? '') ?? 0;
  }

  double valorUnitarioDe(Map<String, dynamic> producao) {
    return double.parse(producao['valor_unitario'].toString());
  }

  List<Map<String, dynamic>> get itensSelecionados {
    return producoes.where((p) => quantidadeDe(p) > 0).toList();
  }

  int get quantidadeTotal {
    return itensSelecionados.fold(0, (soma, p) => soma + quantidadeDe(p));
  }

  double get valorTotal {
    return itensSelecionados.fold(
      0,
      (soma, p) => soma + quantidadeDe(p) * valorUnitarioDe(p),
    );
  }

  double get valorComissao => valorTotal * comissao / 100;

  double get valorProdutor => valorTotal - valorComissao;

  String dinheiro(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> comprar() async {
    final itens = itensSelecionados;

    if (itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe a quantidade de ao menos uma produção')),
      );
      return;
    }

    for (final p in itens) {
      if (quantidadeDe(p) > p['estoque']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Estoque insuficiente na produção de ${p['produtor']} '
              '(disponível: ${p['estoque']})',
            ),
          ),
        );
        return;
      }
    }

    setState(() => comprando = true);

    try {
      final resultado = await ApiService.post(
        'vendas/comprar.php',
        {
          'usuario_id': widget.usuario['id'],
          'itens': itens
              .map((p) => {
                    'producao_id': p['id'],
                    'quantidade': quantidadeDe(p),
                  })
              .toList(),
        },
      );

      if (!mounted) return;

      await mostrarCompra(resultado);
      await carregarProducoes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => comprando = false);
      }
    }
  }

  Future<void> mostrarCompra(Map<String, dynamic> compra) {
    final itens = (compra['itens'] as List)
        .map((i) => Map<String, dynamic>.from(i))
        .toList();

    double numero(dynamic v) => double.parse(v.toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(compra['mensagem']),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final i in itens)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${i['produtor']}: ${i['quantidade']} x '
                    '${dinheiro(numero(i['valor_unitario']))} = '
                    '${dinheiro(numero(i['valor_total']))}',
                  ),
                ),
              const Divider(),
              Text('Quantidade total: ${compra['quantidade_total']} trufas'),
              Text(
                'Comissão (${numero(compra['comissao']).toStringAsFixed(2)}%): '
                '${dinheiro(numero(compra['valor_comissao']))}',
              ),
              Text('Valor ao produtor: ${dinheiro(numero(compra['valor_produtor']))}'),
              const SizedBox(height: 8),
              Text(
                'Valor total: ${dinheiro(numero(compra['valor_total']))}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Vendedor'),
        actions: [
          IconButton(
            onPressed: carregarProducoes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
          IconButton(
            onPressed: sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Olá, ${widget.usuario['nome']}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comissão atual: ${comissao.toStringAsFixed(2)}%',
                  style: const TextStyle(fontSize: 18, color: Colors.brown),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Produções disponíveis',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (producoes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('Nenhuma produção disponível no momento.'),
                  ),
                for (final p in producoes) cardProducao(p),
                const SizedBox(height: 24),
                const Text(
                  'Resumo da compra',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                linhaValor('Quantidade de trufas', '$quantidadeTotal'),
                linhaValor(
                  'Comissão (${comissao.toStringAsFixed(2)}%)',
                  dinheiro(valorComissao),
                ),
                linhaValor('Valor ao produtor', dinheiro(valorProdutor)),
                const Divider(height: 30),
                linhaValor('Valor total', dinheiro(valorTotal), destaque: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: comprando ? null : comprar,
                    child: comprando
                        ? const CircularProgressIndicator()
                        : const Text('Comprar'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget cardProducao(Map<String, dynamic> p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produtor: ${p['produtor']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Estoque: ${p['estoque']} trufas'),
                  Text('Valor: ${dinheiro(valorUnitarioDe(p))} cada'),
                ],
              ),
            ),
            SizedBox(
              width: 90,
              child: TextField(
                controller: controllers[p['id']],
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Qtd.',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget linhaValor(String titulo, String valor, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              titulo,
              style: TextStyle(
                fontWeight: destaque ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: destaque ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: destaque ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }
}
