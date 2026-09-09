class Pergunta {
  const Pergunta(this.texto, this.respostas);

  final String texto;
  final List<String> respostas;

  List<String> embaralha() {
    var copia = [...respostas];

    copia.shuffle();

    return copia;
  }
}
