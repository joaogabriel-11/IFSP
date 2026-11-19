
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

$nome = trim($dados["nome"] ?? "");
$email = trim($dados["email"] ?? "");
$senha = $dados["senha"] ?? "";
$perfil = $dados["perfil"] ?? "";

if (!$nome || !$email || !$senha || !$perfil) {
    http_response_code(400);
    echo json_encode(["erro" => "Preencha todos os campos"]);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(["erro" => "E-mail inválido"]);
    exit;
}

if (!in_array($perfil, ["produtor", "vendedor"])) {
    http_response_code(400);
    echo json_encode(["erro" => "Perfil inválido"]);
    exit;
}

try {
    $senhaHash = password_hash($senha, PASSWORD_DEFAULT);

    $sql = "INSERT INTO usuarios (nome, email, senha, perfil)
            VALUES (:nome, :email, :senha, :perfil)";

    $stmt = $pdo->prepare($sql);

    $stmt->execute([
        ":nome" => $nome,
        ":email" => $email,
        ":senha" => $senhaHash,
        ":perfil" => $perfil
    ]);

    echo json_encode([
        "mensagem" => "Cadastro realizado com sucesso"
    ]);

} catch (PDOException $e) {
    if ($e->getCode() == 23000) {
        http_response_code(409);
        echo json_encode(["erro" => "E-mail já cadastrado"]);
    } else {
        http_response_code(500);
        echo json_encode(["erro" => "Erro ao cadastrar usuário"]);
    }
}
