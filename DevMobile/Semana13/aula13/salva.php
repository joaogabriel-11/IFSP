<?php
header('Access-Control-Allow-Origin: *');

$texto = $_GET["txt"] ?? '';

if (trim($texto) === '') {
    echo "Erro: texto vazio!";
    exit;
}

$dsn = 'mysql:dbname=banco;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

// Parâmetro :texto em vez de colocar a variável direto no SQL (evita SQL injection)
$sth = $dbh->prepare("INSERT INTO `textos` (`id`, `texto`) VALUES (NULL, :texto)");
$resultado = $sth->execute([':texto' => $texto]);

if ($resultado) {
    echo "Texto salvo!";
} else {
    echo "Erro ao salvar!";
}
?>
