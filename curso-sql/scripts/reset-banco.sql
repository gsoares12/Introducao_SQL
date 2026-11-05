-- =====================================================================
-- reset-banco.sql
-- Recria as tabelas do curso (aluno, curso, aluno_curso, funcionarios)
-- com dados de exemplo, no estado esperado a partir do Módulo 4.
--
-- Como usar:
--   1. Crie o banco uma única vez (conectado ao banco "postgres"):
--        CREATE DATABASE alura;
--   2. Conecte-se ao banco "alura" e execute ESTE arquivo inteiro:
--        pgAdmin: Query Tool no banco alura > abrir arquivo > F5
--        psql:    \c alura   e depois   \i 'C:/caminho/curso-sql/scripts/reset-banco.sql'
--
-- ATENÇÃO: apaga e recria essas tabelas (os dados atuais delas serão perdidos).
-- =====================================================================

DROP TABLE IF EXISTS aluno_curso;
DROP TABLE IF EXISTS aluno CASCADE;
DROP TABLE IF EXISTS curso CASCADE;
DROP TABLE IF EXISTS categoria CASCADE;
DROP TABLE IF EXISTS funcionarios;

CREATE TABLE aluno (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(255) NOT NULL,
    cpf             CHAR(11),
    idade           INTEGER,
    ativo           BOOLEAN DEFAULT TRUE
);

CREATE TABLE curso (
    id   INTEGER PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);

CREATE TABLE aluno_curso (
    aluno_id INTEGER,
    curso_id INTEGER,
    PRIMARY KEY (aluno_id, curso_id),

    FOREIGN KEY (aluno_id) REFERENCES aluno (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (curso_id) REFERENCES curso (id)
);

CREATE TABLE funcionarios (
    id        SERIAL PRIMARY KEY,
    matricula VARCHAR(10),
    nome      VARCHAR(255),
    sobrenome VARCHAR(255)
);

INSERT INTO aluno (nome, cpf, idade, ativo) VALUES
    ('Diogo',         '12345678901', 35,   TRUE),
    ('Vinícius Dias', '10987654321', 28,   TRUE),
    ('Nico Steppat',  NULL,          38,   FALSE),
    ('João Roberto',  NULL,          NULL, TRUE),
    ('Diego',         '11122233344', 22,   NULL);

INSERT INTO curso (id, nome) VALUES
    (1, 'HTML'),
    (2, 'Javascript'),
    (3, 'CSS');

-- Nico (3) e João (4) sem curso; CSS (3) sem aluno
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES
    (1, 1),
    (1, 2),
    (2, 1),
    (2, 2),
    (5, 1);

INSERT INTO funcionarios (matricula, nome, sobrenome) VALUES
    ('M001', 'Diogo',    'Mascarenha'),
    ('M002', 'Vinicius', 'Dias'),
    ('M003', 'Nico',     'Steppat'),
    ('M004', 'João',     'Roberto'),
    ('M005', 'Diogo',    'Mascarenha'),
    ('M006', 'Alberto',  'Martins'),
    ('M007', 'Diogo',    'Oliveira');

-- Conferência
SELECT 'aluno' AS tabela, COUNT(*) FROM aluno
UNION ALL SELECT 'curso', COUNT(*) FROM curso
UNION ALL SELECT 'aluno_curso', COUNT(*) FROM aluno_curso
UNION ALL SELECT 'funcionarios', COUNT(*) FROM funcionarios;
