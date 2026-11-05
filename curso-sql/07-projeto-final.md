# Módulo 7 — Projeto final: sistema de biblioteca

Junte tudo o que aprendeu. Tente resolver **sem olhar o gabarito**.

## Requisitos

Uma biblioteca precisa controlar:
- **Autores**: nome (obrigatório) e país.
- **Livros**: título (obrigatório), ano de publicação, preço, e o autor (todo livro tem um autor;
  um autor pode ter vários livros → relação 1:N).
- **Leitores**: nome (obrigatório), e-mail (obrigatório e único) e se está ativo (padrão: sim).
- **Empréstimos**: qual leitor pegou qual livro, data do empréstimo e data de devolução
  (vazia enquanto não devolvido). Se um leitor for excluído, seus empréstimos também devem ser.
  Um livro com histórico de empréstimos **não** pode ser excluído.

## Tarefas

1. Crie o banco `biblioteca` e conecte-se a ele.
2. Crie as 4 tabelas com as chaves primárias, estrangeiras e restrições adequadas.
3. Cadastre ao menos 3 autores, 6 livros, 4 leitores e 8 empréstimos (alguns ainda não devolvidos).
4. Consultas:
   1. Livros com o nome do autor, ordenados por título.
   2. Livros publicados entre 1950 e 2000.
   3. Livros cujo título contém a palavra "de" (ignorando maiúsculas).
   4. Empréstimos em aberto (não devolvidos), com nome do leitor e título do livro.
   5. Quantidade de livros por autor, incluindo autores sem livros.
   6. Preço médio, mais caro e mais barato dos livros.
   7. Leitores com mais de 2 empréstimos.
   8. Os 3 livros mais emprestados.
   9. Livros que nunca foram emprestados.
5. Marque todos os empréstimos em aberto do leitor 1 como devolvidos hoje (`CURRENT_DATE`).
6. Exclua um leitor e confirme que os empréstimos dele sumiram.
7. Tente excluir um livro que já foi emprestado e explique o erro.

<details><summary>Gabarito</summary>

```sql
-- 1 (conectado em postgres)
CREATE DATABASE biblioteca;
-- agora conecte em biblioteca (\c biblioteca ou novo Query Tool)

-- 2
CREATE TABLE autor (
    id   SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    pais VARCHAR(60)
);

CREATE TABLE livro (
    id       SERIAL PRIMARY KEY,
    titulo   VARCHAR(200) NOT NULL,
    ano      INTEGER,
    preco    NUMERIC(8,2) CHECK (preco >= 0),
    autor_id INTEGER NOT NULL REFERENCES autor (id)
);

CREATE TABLE leitor (
    id    SERIAL PRIMARY KEY,
    nome  VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE emprestimo (
    id              SERIAL PRIMARY KEY,
    leitor_id       INTEGER NOT NULL REFERENCES leitor (id) ON DELETE CASCADE,
    livro_id        INTEGER NOT NULL REFERENCES livro (id) ON DELETE RESTRICT,
    data_emprestimo DATE NOT NULL DEFAULT CURRENT_DATE,
    data_devolucao  DATE
);

-- 3
INSERT INTO autor (nome, pais) VALUES
    ('Machado de Assis', 'Brasil'),
    ('Clarice Lispector', 'Brasil'),
    ('Gabriel García Márquez', 'Colômbia'),
    ('Autor Sem Livros', 'Portugal');

INSERT INTO livro (titulo, ano, preco, autor_id) VALUES
    ('Dom Casmurro', 1899, 29.90, 1),
    ('Memórias Póstumas de Brás Cubas', 1881, 34.50, 1),
    ('A Hora da Estrela', 1977, 39.90, 2),
    ('Laços de Família', 1960, 42.00, 2),
    ('Cem Anos de Solidão', 1967, 59.90, 3),
    ('O Amor nos Tempos do Cólera', 1985, 54.90, 3);

INSERT INTO leitor (nome, email) VALUES
    ('Ana',   'ana@email.com'),
    ('Bruno', 'bruno@email.com'),
    ('Carla', 'carla@email.com'),
    ('Davi',  'davi@email.com');

INSERT INTO emprestimo (leitor_id, livro_id, data_emprestimo, data_devolucao) VALUES
    (1, 1, '2026-09-01', '2026-09-10'),
    (1, 3, '2026-09-15', NULL),
    (1, 5, '2026-10-01', NULL),
    (2, 1, '2026-09-05', '2026-09-20'),
    (2, 5, '2026-10-02', '2026-10-15'),
    (3, 1, '2026-10-10', NULL),
    (3, 5, '2026-10-20', NULL),
    (4, 2, '2026-10-25', NULL);

-- 4.1
SELECT livro.titulo, autor.nome AS autor
  FROM livro
  JOIN autor ON autor.id = livro.autor_id
 ORDER BY livro.titulo;

-- 4.2
SELECT * FROM livro WHERE ano BETWEEN 1950 AND 2000;

-- 4.3
SELECT * FROM livro WHERE titulo ILIKE '% de %';

-- 4.4
SELECT leitor.nome, livro.titulo, emprestimo.data_emprestimo
  FROM emprestimo
  JOIN leitor ON leitor.id = emprestimo.leitor_id
  JOIN livro  ON livro.id  = emprestimo.livro_id
 WHERE emprestimo.data_devolucao IS NULL;

-- 4.5
SELECT autor.nome, COUNT(livro.id) AS qtd_livros
  FROM autor
  LEFT JOIN livro ON livro.autor_id = autor.id
 GROUP BY autor.id, autor.nome
 ORDER BY qtd_livros DESC;

-- 4.6
SELECT ROUND(AVG(preco), 2) AS media, MAX(preco) AS mais_caro, MIN(preco) AS mais_barato
  FROM livro;

-- 4.7
SELECT leitor.nome, COUNT(*) AS emprestimos
  FROM emprestimo
  JOIN leitor ON leitor.id = emprestimo.leitor_id
 GROUP BY leitor.id, leitor.nome
HAVING COUNT(*) > 2;

-- 4.8
SELECT livro.titulo, COUNT(*) AS vezes
  FROM emprestimo
  JOIN livro ON livro.id = emprestimo.livro_id
 GROUP BY livro.id, livro.titulo
 ORDER BY vezes DESC
 LIMIT 3;

-- 4.9
SELECT livro.titulo
  FROM livro
  LEFT JOIN emprestimo ON emprestimo.livro_id = livro.id
 WHERE emprestimo.id IS NULL;

-- 5
UPDATE emprestimo
   SET data_devolucao = CURRENT_DATE
 WHERE leitor_id = 1
   AND data_devolucao IS NULL;

-- 6
DELETE FROM leitor WHERE id = 4;
SELECT * FROM emprestimo WHERE leitor_id = 4;   -- vazio (CASCADE)

-- 7
DELETE FROM livro WHERE id = 1;
-- ERROR: update or delete on table "livro" violates foreign key constraint
-- "emprestimo_livro_id_fkey" on table "emprestimo"
-- Motivo: ON DELETE RESTRICT protege o histórico de empréstimos.
```

</details>

## Próximos passos

Depois de dominar este curso, estude: subconsultas (`WHERE id IN (SELECT ...)`),
`CASE WHEN`, funções de texto e data (`UPPER`, `LENGTH`, `EXTRACT`, `AGE`), `UNION`,
*views* (`CREATE VIEW`), índices (`CREATE INDEX`), transações e backup com `pg_dump`.

Consulte também o [Resumo de comandos](resumo-comandos.md).
