
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

$dados = json_decode(file_get_contents("php://input"), true);

$usuarioId = filter_var(
    $dados["usuario_id"] ?? null,
    FILTER_VALIDATE_INT
);

$quantidade = filter_var(
    $dados["quantidade"] ?? null,
    FILTER_VALIDATE_INT
);

$valorUnitario = $dados["valor_unitario"] ?? null;

if (!$usuarioId || !$quantidade || !is_numeric($valorUnitario) ||
    $quantidade <= 0 || $valorUnitario <= 0) {

    http_response_code(400);
    echo json_encode(["erro" => "Dados inválidos"]);
    exit;
}

try {
    // Verificar se o usuário existe e é produtor
    $sql = "SELECT id FROM usuarios
            WHERE id = :id AND perfil = 'produtor'";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([":id" => $usuarioId]);

    if (!$stmt->fetch()) {
        http_response_code(403);
        echo json_encode(["erro" => "Usuário não é produtor"]);
        exit;
    }

    // Consultar comissão
    $stmt = $pdo->query(
        "SELECT comissao FROM configuracoes WHERE id = 1"
    );

    $config = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$config) {
        http_response_code(500);
        echo json_encode(["erro" => "Comissão não configurada"]);
        exit;
    }

    $comissao = (float) $config["comissao"];
    $valorUnitario = round((float) $valorUnitario, 2);

    // Calcular valores no servidor
    $valorTotal = round($quantidade * $valorUnitario, 2);

    $valorDesconto = round(
        $valorTotal * ($comissao / 100),
        2
    );

    $valorLiquido = round(
        $valorTotal - $valorDesconto,
        2
    );

    // Salvar produção
    $sql = "INSERT INTO producoes (
                usuario_id,
                quantidade,
                valor_unitario,
                valor_total,
                comissao,
                valor_desconto,
                valor_liquido
            ) VALUES (
                :usuario_id,
                :quantidade,
                :valor_unitario,
                :valor_total,
                :comissao,
                :valor_desconto,
                :valor_liquido
            )";

    $stmt = $pdo->prepare($sql);

    $stmt->execute([
        ":usuario_id" => $usuarioId,
        ":quantidade" => $quantidade,
        ":valor_unitario" => $valorUnitario,
        ":valor_total" => $valorTotal,
        ":comissao" => $comissao,
        ":valor_desconto" => $valorDesconto,
        ":valor_liquido" => $valorLiquido
    ]);

    echo json_encode([
        "mensagem" => "Produção registrada com sucesso",
        "producao" => [
            "quantidade" => $quantidade,
            "valor_unitario" => $valorUnitario,
            "valor_total" => $valorTotal,
            "comissao" => $comissao,
            "valor_desconto" => $valorDesconto,
            "valor_liquido" => $valorLiquido
        ]
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao registrar produção"]);
}
