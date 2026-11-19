import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class GerenteScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const GerenteScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<GerenteScreen> createState() => _GerenteScreenState();
}

class _GerenteScreenState extends State<GerenteScreen> {
  final comissaoController = TextEditingController();

  int totalProduzido = 0;
  int totalVendido = 0;
  double comissao = 0;
  double lucroMes = 0;

  bool carregando = true;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    carregarResumo();
  }

  @override
  void dispose() {
    comissaoController.dispose();
    super.dispose();
  }

  Future<void> carregarResumo() async {
    setState(() => carregando = true);

    try {
      final resultado = await ApiService.get('gerente/resumo.php');

      if (!mounted) return;

      setState(() {
        totalProduzido = int.parse(resultado['total_produzido'].toString());
        totalVendido = int.parse(resultado['total_vendido'].toString());
        comissao = double.parse(resultado['comissao'].toString());
        lucroMes = double.parse(resultado['lucro_mes'].toString());
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

  Future<void> salvarComissao() async {
    final nova = double.tryParse(
      comissaoController.text.replaceAll(',', '.'),
    );

    if (nova == null || nova < 0 || nova > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma comissão entre 0 e 100')),
      );
      return;
    }

    setState(() => salvando = true);

    try {
      final resultado = await ApiService.post(
        'gerente/comissao.php',
        {
          'usuario_id': widget.usuario['id'],
          'comissao': nova,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['mensagem'])),
      );

      comissaoController.clear();
      await carregarResumo();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => salvando = false);
      }
    }
  }

  String dinheiro(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
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
        title: const Text('Área do Gerente'),
        actions: [
          IconButton(
            onPressed: carregarResumo,
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
          : RefreshIndicator(
              onRefresh: carregarResumo,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Olá, ${widget.usuario['nome']}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  cardInfo(
                    Icons.inventory,
                    'Trufas produzidas',
                    '$totalProduzido',
                  ),
                  cardInfo(
                    Icons.shopping_cart,
                    'Trufas vendidas',
                    '$totalVendido',
                  ),
                  cardInfo(
                    Icons.attach_money,
                    'Lucro da empresa no mês',
                    dinheiro(lucroMes),
                    cor: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Comissão',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Comissão atual: ${comissao.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 18, color: Colors.brown),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: comissaoController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nova comissão (%)',
                      helperText: 'Válida apenas para novas vendas',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: salvando ? null : salvarComissao,
                      child: salvando
                          ? const CircularProgressIndicator()
                          : const Text('Salvar comissão'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget cardInfo(IconData icone, String titulo, String valor, {Color? cor}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icone, color: Colors.brown, size: 32),
        title: Text(titulo),
        trailing: Text(
          valor,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ),
    );
  }
}
