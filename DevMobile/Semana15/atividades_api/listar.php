<?php
require 'conexao.php';

// Lê mês e ano da URL: listar.php?mes=11&ano=2026
$mes = (int) ($_GET['mes'] ?? 0);
$ano = (int) ($_GET['ano'] ?? 0);

// Busca as atividades do mês, ordenadas por data
$sql = $pdo->prepare('SELECT id, descricao, data FROM atividades
                      WHERE MONTH(data) = ? AND YEAR(data) = ?
                      ORDER BY data');
$sql->execute([$mes, $ano]);

// Devolve a lista em JSON
echo json_encode($sql->fetchAll(PDO::FETCH_ASSOC));
