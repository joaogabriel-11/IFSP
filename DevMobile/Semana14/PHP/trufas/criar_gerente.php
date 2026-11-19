
<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "config/database.php";

$nome = "Gerente";
$email = "gerente@trufas.com";
$senha = "Gerente@123";

$senhaHash = password_hash($senha, PASSWORD_DEFAULT);

$sql = "INSERT INTO usuarios (nome, email, senha, perfil)
        VALUES (:nome, :email, :senha, 'gerente')";

$stmt = $pdo->prepare($sql);

try {
    $stmt->execute([
        ":nome" => $nome,
        ":email" => $email,
        ":senha" => $senhaHash
    ]);

    echo "Gerente cadastrado com sucesso!";

} catch (PDOException $e) {
    echo "Gerente já cadastrado ou ocorreu um erro.";
}
