<?php
require 'conexao.php';

// Lê o JSON enviado no corpo do POST
$dados = json_decode(file_get_contents('php://input'), true);
$descricao = trim($dados['descricao'] ?? '');
$data = $dados['data'] ?? '';

// Valida se os campos não estão vazios
if ($descricao === '' || $data === '') {
    echo json_encode(['sucesso' => false, 'erro' => 'Campos vazios']);
    exit;
}

// Insere com prepared statement (evita SQL Injection)
try {
    $sql = $pdo->prepare('INSERT INTO atividades (descricao, data) VALUES (?, ?)');
    $sql->execute([$descricao, $data]);
    echo json_encode(['sucesso' => true]);
} catch (PDOException $e) {
    echo json_encode(['sucesso' => false, 'erro' => $e->getMessage()]);
}
