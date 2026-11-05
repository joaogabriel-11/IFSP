<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

$id = (int) ($_GET["id"] ?? 0);

$dsn = 'mysql:dbname=banco;host=127.0.0.1;charset=utf8mb4';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

// ORDER BY + LIMIT 1 garante que vem exatamente o PRÓXIMO texto
$sth = $dbh->prepare("SELECT * FROM `textos` WHERE `id` > :id ORDER BY `id` LIMIT 1");
$sth->execute([':id' => $id]);

$resultado = $sth->fetch(PDO::FETCH_ASSOC);

if ($resultado) {
    $resultado['id'] = (int) $resultado['id']; // id como número no JSON, igual ao exemplo
    echo json_encode($resultado, JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode(["erro" => "Nenhum texto encontrado"], JSON_UNESCAPED_UNICODE);
}
?>
