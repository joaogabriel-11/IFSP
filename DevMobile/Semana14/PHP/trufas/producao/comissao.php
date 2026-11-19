
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

require_once "../config/cors.php";
require_once "../config/database.php";

try {
    $sql = "SELECT comissao FROM configuracoes WHERE id = 1";
    $stmt = $pdo->query($sql);

    $config = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$config) {
        http_response_code(404);
        echo json_encode(["erro" => "Comissão não encontrada"]);
        exit;
    }

    echo json_encode([
        "comissao" => (float) $config["comissao"]
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao consultar comissão"]);
}
