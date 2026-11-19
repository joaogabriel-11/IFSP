<?php

require_once "../config/cors.php";
require_once "../config/database.php";

// Totais de producao e vendas, comissao atual e lucro da empresa no mes
try {
    $totalProduzido = (int) $pdo->query(
        "SELECT COALESCE(SUM(quantidade), 0) FROM producoes"
    )->fetchColumn();

    $totalVendido = (int) $pdo->query(
        "SELECT COALESCE(SUM(quantidade), 0) FROM vendas"
    )->fetchColumn();

    // Lucro da empresa = comissoes das vendas do mes atual
    $lucroMes = (float) $pdo->query(
        "SELECT COALESCE(SUM(valor_comissao), 0) FROM vendas
         WHERE YEAR(data_venda) = YEAR(CURRENT_DATE())
           AND MONTH(data_venda) = MONTH(CURRENT_DATE())"
    )->fetchColumn();

    $comissao = (float) $pdo->query(
        "SELECT comissao FROM configuracoes WHERE id = 1"
    )->fetchColumn();

    echo json_encode([
        "total_produzido" => $totalProduzido,
        "total_vendido" => $totalVendido,
        "comissao" => $comissao,
        "lucro_mes" => round($lucroMes, 2)
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao consultar resumo"]);
}
