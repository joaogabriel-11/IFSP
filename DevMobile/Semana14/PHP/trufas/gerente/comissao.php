<?php

require_once "../config/cors.php";
require_once "../config/database.php";

// Altera o percentual de comissao (vale apenas para novas vendas,
// pois cada venda guarda a comissao usada no momento da compra)
$dados = json_decode(file_get_contents("php://input"), true);

$usuarioId = filter_var($dados["usuario_id"] ?? null, FILTER_VALIDATE_INT);
$comissao = $dados["comissao"] ?? null;

if (!$usuarioId || !is_numeric($comissao) || $comissao < 0 || $comissao > 100) {
    http_response_code(400);
    echo json_encode(["erro" => "Informe uma comissão entre 0 e 100"]);
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE id = :id AND perfil = 'gerente'");
    $stmt->execute([":id" => $usuarioId]);

    if (!$stmt->fetch()) {
        http_response_code(403);
        echo json_encode(["erro" => "Apenas o gerente pode alterar a comissão"]);
        exit;
    }

    $comissao = round((float) $comissao, 2);

    $stmt = $pdo->prepare("UPDATE configuracoes SET comissao = :comissao WHERE id = 1");
    $stmt->execute([":comissao" => $comissao]);

    echo json_encode([
        "mensagem" => "Comissão atualizada para novas vendas",
        "comissao" => $comissao
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao atualizar comissão"]);
}
