import 'package:flutter/material.dart';
import 'api.dart';

void main() => runApp(const MyApp());

// Widget raiz do app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Atividades',
      debugShowCheckedModeBanner: false,
      home: TelaPrincipal(),
    );
  }
}

// Nomes dos meses para mostrar no topo
const meses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
];

// ================= TELA PRINCIPAL =================
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  late int mes; // mês selecionado
  late int ano; // ano selecionado
  List<dynamic> atividades = []; // atividades vindas da API
  bool carregando = false; // controla o CircularProgressIndicator

  @override
  void initState() {
    super.initState();
    // Começa no mês/ano atual e já carrega a lista
    final hoje = DateTime.now();
    mes = hoje.month;
    ano = hoje.year;
    carregar();
  }

  // Busca as atividades do mês selecionado na API
  Future<void> carregar() async {
    setState(() => carregando = true);
    try {
      final lista = await Api.listar(mes, ano);
      setState(() => atividades = lista);
    } catch (e) {
      setState(() => atividades = []);
      mostrarMensagem('Erro ao conectar com a API');
    }
    setState(() => carregando = false);
  }

  // Muda o mês: -1 = anterior, +1 = seguinte
  void mudarMes(int passo) {
    setState(() {
      mes += passo;
      if (mes < 1) {
        mes = 12;
        ano--;
      }
      if (mes > 12) {
        mes = 1;
        ano++;
      }
    });
    carregar();
  }

  // Verdadeiro se o mês selecionado é o mês atual (bloqueia a seta →)
  bool get ehMesAtual {
    final hoje = DateTime.now();
    return mes == hoje.month && ano == hoje.year;
  }

  void mostrarMensagem(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  // Abre o diálogo de cadastro passando mês/ano por parâmetro
  Future<void> abrirCadastro() async {
    final sucesso = await showDialog<bool>(
      context: context,
      builder: (_) => CadastroDialog(mes: mes, ano: ano),
    );
    if (sucesso == null || !mounted) return; // usuário cancelou
    mostrarMensagem(sucesso ? 'Atividade salva!' : 'Erro ao salvar');
    if (sucesso) carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atividades do Dia')),
      body: Column(
        children: [
          // Topo: setas e mês/ano selecionado
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => mudarMes(-1),
              ),
              Text('${meses[mes - 1]}/$ano',
                  style: const TextStyle(fontSize: 20)),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                // null desabilita o botão quando já está no mês atual
                onPressed: ehMesAtual ? null : () => mudarMes(1),
              ),
            ],
          ),
          // Conteúdo: carregando, vazio ou a lista
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : atividades.isEmpty
                    ? const Center(child: Text('Nenhuma atividade neste mês'))
                    : ListView.builder(
                        itemCount: atividades.length,
                        itemBuilder: (context, i) {
                          final a = atividades[i];
                          // data vem como "2026-11-25": pega só o dia
                          final dia = int.parse(a['data'].substring(8, 10));
                          return ListTile(
                            title: Text('Dia $dia - ${a['descricao']}'),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirCadastro,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ================= DIÁLOGO DE CADASTRO =================
class CadastroDialog extends StatefulWidget {
  final int mes; // recebidos da tela principal
  final int ano;
  const CadastroDialog({super.key, required this.mes, required this.ano});

  @override
  State<CadastroDialog> createState() => _CadastroDialogState();
}

class _CadastroDialogState extends State<CadastroDialog> {
  final diaController = TextEditingController();
  final descricaoController = TextEditingController();
  String? erro; // mensagem de validação

  @override
  void dispose() {
    // Libera os controllers da memória
    diaController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    final dia = int.tryParse(diaController.text);
    final descricao = descricaoController.text.trim();
    // Último dia do mês: dia 0 do mês seguinte (ex.: 30 para novembro)
    final ultimoDia = DateTime(widget.ano, widget.mes + 1, 0).day;

    // Validações
    if (dia == null || dia < 1 || dia > ultimoDia) {
      setState(() => erro = 'Dia inválido (1 a $ultimoDia)');
      return;
    }
    if (descricao.isEmpty) {
      setState(() => erro = 'Digite a atividade');
      return;
    }

    // Monta a data no formato do MySQL: AAAA-MM-DD
    final data = '${widget.ano}-'
        '${widget.mes.toString().padLeft(2, '0')}-'
        '${dia.toString().padLeft(2, '0')}';

    bool sucesso;
    try {
      sucesso = await Api.salvar(descricao, data);
    } catch (e) {
      sucesso = false;
    }
    // Fecha o diálogo devolvendo o resultado para a tela principal
    if (mounted) Navigator.pop(context, sucesso);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nova atividade - ${meses[widget.mes - 1]}/${widget.ano}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: diaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Dia'),
          ),
          TextField(
            controller: descricaoController,
            decoration: const InputDecoration(labelText: 'Atividade'),
          ),
          if (erro != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(erro!, style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: salvar, child: const Text('Salvar')),
      ],
    );
  }
}
