<?php
// Headers: resposta em JSON e CORS liberado (para o Flutter Web)
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// O navegador manda um OPTIONS antes do POST (preflight): só responde OK
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

// Conexão PDO com o MySQL (padrão do XAMPP: usuário root, sem senha)
$pdo = new PDO('mysql:host=localhost;dbname=atividades_db;charset=utf8mb4', 'root', '');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
