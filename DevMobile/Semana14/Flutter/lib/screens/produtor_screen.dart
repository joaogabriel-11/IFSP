import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class ProdutorScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const ProdutorScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<ProdutorScreen> createState() => _ProdutorScreenState();
}

class _ProdutorScreenState extends State<ProdutorScreen> {
  final quantidadeController = TextEditingController();
  final valorController = TextEditingController();

  double comissao = 0;
  bool carregando = true;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    carregarComissao();
  }

  @override
  void dispose() {
    quantidadeController.dispose();
    valorController.dispose();
    super.dispose();
  }

  Future<void> carregarComissao() async {
    try {
      final resultado = await ApiService.get(
        'producao/comissao.php',
      );

      if (!mounted) return;

      setState(() {
        comissao = double.parse(
          resultado['comissao'].toString(),
        );
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => carregando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  double get quantidade {
    return double.tryParse(
          quantidadeController.text,
        ) ??
        0;
  }

  double get valorUnitario {
    return double.tryParse(
          valorController.text.replaceAll(',', '.'),
        ) ??
        0;
  }

  double get valorTotal => quantidade * valorUnitario;

  double get valorDesconto => valorTotal * comissao / 100;

  double get valorLiquido => valorTotal - valorDesconto;

  String dinheiro(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  Future<void> registrarProducao() async {
    if (quantidade <= 0 || quantidade % 1 != 0 || valorUnitario <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma quantidade inteira e um valor válido'),
        ),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      final resultado = await ApiService.post(
        'producao/registrar.php',
        {
          'usuario_id': widget.usuario['id'],
          'quantidade': quantidade.toInt(),
          'valor_unitario': valorUnitario,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['mensagem']),
        ),
      );

      quantidadeController.clear();
      valorController.clear();

      setState(() {});
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Produtor'),
        actions: [
          IconButton(
            onPressed: sair,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Registrar produção',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: quantidadeController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Quantidade de trufas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valorController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Valor unitário (R\$)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Resumo da produção',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  linhaValor('Valor total', dinheiro(valorTotal)),
                  linhaValor(
                    'Desconto da comissão (${comissao.toStringAsFixed(2)}%)',
                    dinheiro(valorDesconto),
                  ),
                  const Divider(height: 30),
                  linhaValor(
                    'Valor líquido',
                    dinheiro(valorLiquido),
                    destaque: true,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: salvando ? null : registrarProducao,
                      child: salvando
                          ? const CircularProgressIndicator()
                          : const Text('Registrar produção'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget linhaValor(
    String titulo,
    String valor, {
    bool destaque = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
