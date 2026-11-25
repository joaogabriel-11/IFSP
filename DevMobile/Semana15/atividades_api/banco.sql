-- Cria o banco e a tabela de atividades
CREATE DATABASE IF NOT EXISTS atividades_db;
USE atividades_db;

CREATE TABLE IF NOT EXISTS atividades (
  id INT AUTO_INCREMENT PRIMARY KEY,
  descricao VARCHAR(255) NOT NULL,
  data DATE NOT NULL
);
