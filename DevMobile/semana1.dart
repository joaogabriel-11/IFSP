void main() {
  String nome = "Camiseta ADS";
  int quantidade = 3;
  double preco = 49.90;
  bool disponivel = true;
  double imposto = 5.0;
  
  var total = (quantidade * preco)*(1 + imposto/100);
  
  print("Produto: $nome");
  print("Disponivel em estoque: $disponivel");
  print("Quantidade: $quantidade");
  print("Preo unitário: $preco");
  print("Valor Total: R\$${total}");
}
