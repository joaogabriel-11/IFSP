class Produto {
  final int id;
  final String titulo;
  final double preco;
  final String categoria;
  final double avaliacao;

  const Produto({
    required this.id,
    required this.titulo,
    required this.preco,
    required this.categoria,
    required this.avaliacao,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] as int,
      titulo: json['title'] as String,
      preco: (json['price'] as num).toDouble(),
      categoria: json['category'] as String,
      avaliacao: (json['rating'] as num).toDouble(),
    );
  }
}
