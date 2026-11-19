<?php

require_once "../config/cors.php";
require_once "../config/database.php";

$dados = json_decode(file_get_contents("php://input"), true);

$vendedorId = filter_var($dados["usuario_id"] ?? null, FILTER_VALIDATE_INT);
$itens = $dados["itens"] ?? [];

if (!$vendedorId || !is_array($itens) || count($itens) == 0) {
    http_response_code(400);
    echo json_encode(["erro" => "Informe ao menos uma trufa para comprar"]);
    exit;
}

try {
    // Verificar se o usuario e vendedor
    $stmt = $pdo->prepare("SELECT id FROM usuarios WHERE id = :id AND perfil = 'vendedor'");
    $stmt->execute([":id" => $vendedorId]);

    if (!$stmt->fetch()) {
        http_response_code(403);
        echo json_encode(["erro" => "Usuário não é vendedor"]);
        exit;
    }

    $pdo->beginTransaction();

    // Comissao atual (vale para esta nova venda)
    $config = $pdo->query("SELECT comissao FROM configuracoes WHERE id = 1")
                  ->fetch(PDO::FETCH_ASSOC);
    $comissao = (float) ($config["comissao"] ?? 0);

    $compra = [];
    $totalQuantidade = 0;
    $totalValor = 0;
    $totalComissao = 0;
    $totalProdutor = 0;

    foreach ($itens as $item) {
        $producaoId = filter_var($item["producao_id"] ?? null, FILTER_VALIDATE_INT);
        $quantidade = filter_var($item["quantidade"] ?? null, FILTER_VALIDATE_INT);

        if (!$producaoId || !$quantidade || $quantidade <= 0) {
            throw new InvalidArgumentException("Quantidade inválida");
        }

        // Bloqueia a producao para evitar vender acima do estoque
        $stmt = $pdo->prepare(
            "SELECT p.id, p.quantidade, p.valor_unitario, u.nome AS produtor
             FROM producoes p
             JOIN usuarios u ON u.id = p.usuario_id
             WHERE p.id = :id
             FOR UPDATE"
        );
        $stmt->execute([":id" => $producaoId]);
        $producao = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$producao) {
            throw new InvalidArgumentException("Produção não encontrada");
        }

        $stmt = $pdo->prepare("SELECT COALESCE(SUM(quantidade), 0) FROM vendas WHERE producao_id = :id");
        $stmt->execute([":id" => $producaoId]);
        $estoque = (int) $producao["quantidade"] - (int) $stmt->fetchColumn();

        if ($quantidade > $estoque) {
            throw new InvalidArgumentException(
                "Estoque insuficiente para a produção de " . $producao["produtor"] .
                " (disponível: $estoque)"
            );
        }

        $valorUnitario = (float) $producao["valor_unitario"];
        $valorTotal = round($quantidade * $valorUnitario, 2);
        $valorComissao = round($valorTotal * $comissao / 100, 2);
        $valorProdutor = round($valorTotal - $valorComissao, 2);

        $stmt = $pdo->prepare(
            "INSERT INTO vendas (vendedor_id, producao_id, quantidade, valor_unitario,
                                 valor_total, comissao, valor_comissao, valor_produtor)
             VALUES (:vendedor_id, :producao_id, :quantidade, :valor_unitario,
                     :valor_total, :comissao, :valor_comissao, :valor_produtor)"
        );
        $stmt->execute([
            ":vendedor_id" => $vendedorId,
            ":producao_id" => $producaoId,
            ":quantidade" => $quantidade,
            ":valor_unitario" => $valorUnitario,
            ":valor_total" => $valorTotal,
            ":comissao" => $comissao,
            ":valor_comissao" => $valorComissao,
            ":valor_produtor" => $valorProdutor
        ]);

        $compra[] = [
            "produtor" => $producao["produtor"],
            "quantidade" => $quantidade,
            "valor_unitario" => $valorUnitario,
            "valor_total" => $valorTotal
        ];

        $totalQuantidade += $quantidade;
        $totalValor += $valorTotal;
        $totalComissao += $valorComissao;
        $totalProdutor += $valorProdutor;
    }

    $pdo->commit();

    echo json_encode([
        "mensagem" => "Compra realizada com sucesso",
        "itens" => $compra,
        "comissao" => $comissao,
        "quantidade_total" => $totalQuantidade,
        "valor_total" => round($totalValor, 2),
        "valor_comissao" => round($totalComissao, 2),
        "valor_produtor" => round($totalProdutor, 2)
    ]);

} catch (InvalidArgumentException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    http_response_code(400);
    echo json_encode(["erro" => $e->getMessage()]);

} catch (PDOException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    http_response_code(500);
    echo json_encode(["erro" => "Erro ao registrar compra"]);
}
