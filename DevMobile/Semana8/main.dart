import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Galeria Wiki',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const GaleriaWiki(),
    );
  }
}

// TELA INICIAL - GALERIA DE IMAGENS
class GaleriaWiki extends StatefulWidget {
  const GaleriaWiki({super.key});

  @override
  State<GaleriaWiki> createState() => _GaleriaWikiState();
}

class _GaleriaWikiState extends State<GaleriaWiki> {
  final List<String> imagens = [
    'https://upload.wikimedia.org/wikipedia/commons/3/3a/Cat03.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/6/63/Neptune_-_Voyager_2_%2829347980845%29_flatten_crop.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/5/56/Tiger.50.jpg',
    'https://www.wikipedia.org/portal/wikipedia.org/assets/img/Wikipedia-logo-v2.png',
    'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/dc/French_Battleship_Justice_by_the_Detroit_Publishing_Co%2C_1909.jpg/250px-French_Battleship_Justice_by_the_Detroit_Publishing_Co%2C_1909.jpg?utm_source=pt.wikipedia.org&utm_campaign=parser&utm_content=thumbnail',
    'https://thumb.wikimedia.org/wikipedia/commons/thumb/d/d9/Zabytkowa_cerkiew_wpisana_na_list%C4%99_UNESCO.jpg/960px-Zabytkowa_cerkiew_wpisana_na_list%C4%99_UNESCO.jpg?utm_source=pt.wikipedia.org&utm_campaign=parser&utm_content=thumbnail',
  ];

  final List<String> aprovadas = [];

  Future<void> avaliarImagem(String imagem) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AvaliarFoto(imagem),
      ),
    );

    if (!mounted) return;

    setState(() {
      if (resultado == true) {
        if (!aprovadas.contains(imagem)) {
          aprovadas.add(imagem);
        }
      }

      if (resultado == false) {
        aprovadas.remove(imagem);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria Wiki'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              'Wiki Images',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: imagens.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final imagem = imagens[index];

                return GestureDetector(
                  onTap: () {
                    avaliarImagem(imagem);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: aprovadas.contains(imagem)
                            ? Colors.green
                            : Colors.grey,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        imagem,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FotosAprovadas(aprovadas),
                  ),
                );
              },
              child: const Text('Ver fotos aprovadas'),
            ),
          ),
        ],
      ),
    );
  }
}

// TELA PARA APROVAR OU REPROVAR
class AvaliarFoto extends StatelessWidget {
  const AvaliarFoto(this.imagem, {super.key});

  final String imagem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Foto'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                imagem,
                width: 300,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 300,
                    height: 300,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 80,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('APROVAR'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('REPROVAR'),
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

// TELA FINAL - SOMENTE IMAGENS APROVADAS
class FotosAprovadas extends StatelessWidget {
  const FotosAprovadas(this.aprovadas, {super.key});

  final List<String> aprovadas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fotos Aprovadas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: aprovadas.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma imagem aprovada.',
                style: TextStyle(fontSize: 20),
              ),
            )
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Imagens Selecionadas',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: aprovadas.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          aprovadas[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
