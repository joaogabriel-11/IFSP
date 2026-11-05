<?php
header('Access-Control-Allow-Origin: *');

$descricao = $_POST["desc"] ?? '';

if (!isset($_FILES['foto']) || trim($descricao) === '') {
    echo "Erro: envie a foto e a descrição!";
    exit;
}

// Cria a pasta "fotos" se ainda não existir
if (!is_dir('fotos')) {
    mkdir('fotos');
}

// Nome único para não sobrescrever outra foto
$arquivo = uniqid() . '.jpg';
move_uploaded_file($_FILES['foto']['tmp_name'], "fotos/$arquivo");

$dsn = 'mysql:dbname=banco;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$sth = $dbh->prepare("INSERT INTO `fotos` (`id`, `arquivo`, `descricao`) VALUES (NULL, :arquivo, :descricao)");
$resultado = $sth->execute([':arquivo' => $arquivo, ':descricao' => $descricao]);

if ($resultado) {
    echo "Foto salva!";
} else {
    echo "Erro ao salvar!";
}
?>
