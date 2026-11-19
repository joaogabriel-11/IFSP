
<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once "../config/database.php";

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$dados = json_decode(file_get_contents("php://input"), true);

$email = trim($dados["email"] ?? "");
$senha = $dados["senha"] ?? "";

if (!$email || !$senha) {
    http_response_code(400);
    echo json_encode(["erro" => "Informe e-mail e senha"]);
    exit;
}

$sql = "SELECT id, nome, email, senha, perfil
        FROM usuarios
        WHERE email = :email";

$stmt = $pdo->prepare($sql);
$stmt->execute([":email" => $email]);

$usuario = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$usuario || !password_verify($senha, $usuario["senha"])) {
    http_response_code(401);
    echo json_encode(["erro" => "E-mail ou senha incorretos"]);
    exit;
}

unset($usuario["senha"]);

echo json_encode([
    "mensagem" => "Login realizado com sucesso",
    "usuario" => $usuario
]);
