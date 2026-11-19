<?php

require_once "../config/cors.php";
require_once "../config/database.php";

// Lista as producoes que ainda possuem estoque
try {
    $sql = "SELECT p.id,
                   u.nome AS produtor,
                   p.quantidade,
                   p.valor_unitario,
                   p.quantidade - COALESCE(SUM(v.quantidade), 0) AS estoque
            FROM producoes p
            JOIN usuarios u ON u.id = p.usuario_id
            LEFT JOIN vendas v ON v.producao_id = p.id
            GROUP BY p.id, u.nome, p.quantidade, p.valor_unitario
            HAVING estoque > 0
            ORDER BY p.id DESC";

    $producoes = $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC);

    foreach ($producoes as &$p) {
        $p["id"] = (int) $p["id"];
        $p["quantidade"] = (int) $p["quantidade"];
        $p["estoque"] = (int) $p["estoque"];
        $p["valor_unitario"] = (float) $p["valor_unitario"];
    }

    $config = $pdo->query("SELECT comissao FROM configuracoes WHERE id = 1")
                  ->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "comissao" => (float) ($config["comissao"] ?? 0),
        "producoes" => $producoes
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao listar produções"]);
}
