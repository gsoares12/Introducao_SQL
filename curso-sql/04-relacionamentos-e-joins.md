# Módulo 4 — Restrições, relacionamentos e JOINs

Baseado em `Aula04-atividade01.sql`, `03`, `05` e `07`.

## 4.1 Restrições (constraints)

Restrições são regras que o banco **garante** — nenhum INSERT/UPDATE que as viole é aceito.

### Sem restrições, aceita qualquer coisa

```sql
CREATE TABLE curso (
    id   INTEGER,
    nome VARCHAR(255)
);
INSERT INTO curso (id, nome) VALUES (NULL, NULL);   -- aceito! um curso "fantasma"
DROP TABLE curso;
```

### NOT NULL — campo obrigatório

```sql
CREATE TABLE curso (
    id   INTEGER      NOT NULL,
    nome VARCHAR(255) NOT NULL
);
INSERT INTO curso (id, nome) VALUES (NULL, NULL);    -- ❌ erro
INSERT INTO curso (id, nome) VALUES (1, NULL);       -- ❌ erro
INSERT INTO curso (id, nome) VALUES (1, 'HTML');     -- ✅
INSERT INTO curso (id, nome) VALUES (1, 'Javascript'); -- ✅ aceito... mas id repetido!
DROP TABLE curso;
```

### UNIQUE — sem repetição

```sql
CREATE TABLE curso (
    id   INTEGER      NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL
);
INSERT INTO curso (id, nome) VALUES (1, 'HTML');
INSERT INTO curso (id, nome) VALUES (1, 'Javascript');  -- ❌ id duplicado
DROP TABLE curso;
```

### PRIMARY KEY — a identidade da linha

`PRIMARY KEY` = `NOT NULL` + `UNIQUE` (+ índice para buscas rápidas). Cada tabela deve ter uma.

```sql
CREATE TABLE curso (
    id   INTEGER PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);
INSERT INTO curso (id, nome) VALUES (1, 'HTML');
INSERT INTO curso (id, nome) VALUES (2, 'Javascript');
SELECT * FROM curso;
```

Combinando com `SERIAL`, o banco gera o id:

```sql
DROP TABLE aluno;

CREATE TABLE aluno (
    id   SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL
);
INSERT INTO aluno (nome) VALUES ('Diogo');     -- id 1
INSERT INTO aluno (nome) VALUES ('Vinícius');  -- id 2
```

Outras restrições úteis:

```sql
idade  INTEGER CHECK (idade >= 0),      -- valida uma condição
ativo  BOOLEAN DEFAULT TRUE,            -- valor padrão se não informado
```

## 4.2 Relacionamentos

Um aluno pode fazer vários cursos e um curso tem vários alunos: relação **muitos-para-muitos
(N:N)**. Ela é resolvida com uma **tabela associativa** que guarda os pares:

```
aluno (id, nome)  1 ──── N  aluno_curso (aluno_id, curso_id)  N ──── 1  curso (id, nome)
```

### Primeira tentativa: sem FOREIGN KEY

```sql
CREATE TABLE aluno_curso (
    aluno_id INTEGER,
    curso_id INTEGER,
    PRIMARY KEY (aluno_id, curso_id)   -- chave composta: o PAR não se repete
);

INSERT INTO aluno_curso VALUES (1, 1);   -- Diogo em HTML
INSERT INTO aluno_curso VALUES (2, 1);   -- Vinícius em HTML
INSERT INTO aluno_curso VALUES (3, 1);   -- aluno 3 NÃO existe, mas foi aceito! 😱
DROP TABLE aluno_curso;
```

### FOREIGN KEY — chave estrangeira

A FK garante que o valor **exista** na tabela referenciada:

```sql
CREATE TABLE aluno_curso (
    aluno_id INTEGER,
    curso_id INTEGER,
    PRIMARY KEY (aluno_id, curso_id),

    FOREIGN KEY (aluno_id) REFERENCES aluno (id),
    FOREIGN KEY (curso_id) REFERENCES curso (id)
);

INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (1, 1);  -- ✅
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (2, 1);  -- ✅
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (3, 1);  -- ❌ aluno 3 não existe
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (1, 3);  -- ❌ curso 3 não existe
```

Sintaxe geral:

```sql
FOREIGN KEY (coluna_na_tabela_origem)
REFERENCES tabela_destino (coluna_na_tabela_destino)
    ON DELETE opção
    ON UPDATE opção     -- opções no Módulo 5
```

Outros tipos de relação:
- **1:N** (um cliente tem vários pedidos): a FK fica no lado "N" (`pedido.cliente_id`).
- **1:1**: FK com `UNIQUE`.

## 4.3 JOIN — consultando várias tabelas

### INNER JOIN (ou só JOIN): só o que combina

```sql
SELECT *
  FROM aluno
  JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
  JOIN curso       ON curso.id = aluno_curso.curso_id;
```

O `ON` diz **como** as linhas se ligam. Quando duas tabelas têm colunas com o mesmo nome
(`aluno.nome` e `curso.nome`), qualifique com o nome da tabela e use apelidos:

```sql
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (2, 2);

SELECT aluno.nome AS "Nome do aluno",
       curso.nome AS "Nome do curso"
  FROM aluno
  JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
  JOIN curso       ON curso.id = aluno_curso.curso_id;
```

Apelidos de tabela deixam mais curto:

```sql
SELECT a.nome AS aluno, c.nome AS curso
  FROM aluno a
  JOIN aluno_curso ac ON ac.aluno_id = a.id
  JOIN curso c        ON c.id = ac.curso_id;
```

### Tipos de JOIN

Prepare o cenário: um aluno sem curso e um curso sem aluno.

```sql
INSERT INTO aluno (nome) VALUES ('Nico');        -- não está em nenhum curso
INSERT INTO curso (id, nome) VALUES (3, 'CSS');  -- ninguém matriculado
```

| JOIN | Retorna |
|---|---|
| `JOIN` / `INNER JOIN` | só linhas com correspondência dos dois lados |
| `LEFT JOIN` | **todas** da esquerda + correspondentes da direita (ou `NULL`) |
| `RIGHT JOIN` | **todas** da direita + correspondentes da esquerda (ou `NULL`) |
| `FULL JOIN` | todas de ambos os lados |
| `CROSS JOIN` | todas as combinações possíveis (produto cartesiano), sem `ON` |

```
   INNER          LEFT           RIGHT          FULL
  ( A (█) B )   (█A█(█) B )   ( A (█)█B█)   (█A█(█)█B█)
```

```sql
-- Nico aparece com curso NULL
SELECT aluno.nome AS "Nome do aluno", curso.nome AS "Nome do curso"
  FROM aluno
  LEFT JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
  LEFT JOIN curso       ON curso.id = aluno_curso.curso_id;

-- CSS aparece com aluno NULL
SELECT aluno.nome AS "Nome do aluno", curso.nome AS "Nome do curso"
  FROM aluno
 RIGHT JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
 RIGHT JOIN curso       ON curso.id = aluno_curso.curso_id;

-- Nico e CSS aparecem
SELECT aluno.nome AS "Nome do aluno", curso.nome AS "Nome do curso"
  FROM aluno
  FULL JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
  FULL JOIN curso       ON curso.id = aluno_curso.curso_id;

-- todo aluno com todo curso (nº alunos × nº cursos linhas)
SELECT aluno.nome AS "Nome do aluno", curso.nome AS "Nome do curso"
  FROM aluno
 CROSS JOIN curso;
```

Truque clássico: **encontrar quem NÃO tem relação** usando LEFT JOIN + IS NULL:

```sql
-- alunos sem nenhum curso
SELECT aluno.nome
  FROM aluno
  LEFT JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
 WHERE aluno_curso.aluno_id IS NULL;
```

## Exercícios

> Se o seu banco estiver diferente do esperado, rode [scripts/reset-banco.sql](scripts/reset-banco.sql).

1. Crie a tabela `categoria` (`id` SERIAL PK, `nome` obrigatório e único).
2. Adicione à tabela `curso` a coluna `categoria_id` com FK para `categoria`
   (dica: `ALTER TABLE curso ADD COLUMN categoria_id INTEGER REFERENCES categoria (id);`).
3. Cadastre as categorias "Front-end" e "Programação" e associe os cursos a elas com UPDATE.
4. Liste o nome de cada curso com o nome da sua categoria.
5. Liste todos os cursos, inclusive os sem aluno, com o nome dos alunos.
6. Liste os cursos que não têm nenhum aluno.
7. Tente inserir uma matrícula para um aluno inexistente. Qual erro aparece?

<details><summary>Gabarito</summary>

```sql
-- 1
CREATE TABLE categoria (
    id   SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE
);
-- 2
ALTER TABLE curso ADD COLUMN categoria_id INTEGER REFERENCES categoria (id);
-- 3
INSERT INTO categoria (nome) VALUES ('Front-end'), ('Programação');
UPDATE curso SET categoria_id = 1 WHERE nome IN ('HTML', 'CSS');
UPDATE curso SET categoria_id = 2 WHERE nome = 'Javascript';
-- 4
SELECT curso.nome AS curso, categoria.nome AS categoria
  FROM curso
  JOIN categoria ON categoria.id = curso.categoria_id;
-- 5
SELECT curso.nome AS curso, aluno.nome AS aluno
  FROM curso
  LEFT JOIN aluno_curso ON aluno_curso.curso_id = curso.id
  LEFT JOIN aluno       ON aluno.id = aluno_curso.aluno_id;
-- 6
SELECT curso.nome
  FROM curso
  LEFT JOIN aluno_curso ON aluno_curso.curso_id = curso.id
 WHERE aluno_curso.curso_id IS NULL;
-- 7
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (999, 1);
-- ERROR: insert or update on table "aluno_curso" violates foreign key constraint
-- "aluno_curso_aluno_id_fkey" — Key (aluno_id)=(999) is not present in table "aluno".
```

</details>

Próximo: [Módulo 5 — Integridade referencial](05-integridade-cascade.md)
