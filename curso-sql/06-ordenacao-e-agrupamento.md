# Módulo 6 — Ordenação, paginação, funções de agregação e agrupamento

Baseado em `Aula06-atividade01.sql`, `02`, `04`, `05` e `06`.

Crie a tabela de prática:

```sql
DROP TABLE IF EXISTS funcionarios;

CREATE TABLE funcionarios (
    id        SERIAL PRIMARY KEY,
    matricula VARCHAR(10),
    nome      VARCHAR(255),
    sobrenome VARCHAR(255)
);

INSERT INTO funcionarios (matricula, nome, sobrenome) VALUES
    ('M001', 'Diogo',    'Mascarenha'),
    ('M002', 'Vinicius', 'Dias'),
    ('M003', 'Nico',     'Steppat'),
    ('M004', 'João',     'Roberto'),
    ('M005', 'Diogo',    'Mascarenha'),
    ('M006', 'Alberto',  'Martins'),
    ('M007', 'Diogo',    'Oliveira');
```

## 6.1 ORDER BY — ordenar

Sem `ORDER BY`, **a ordem do resultado não é garantida**.

```sql
SELECT * FROM funcionarios ORDER BY nome;              -- A→Z (ASC é o padrão)
SELECT * FROM funcionarios ORDER BY nome DESC;         -- Z→A
SELECT * FROM funcionarios ORDER BY nome, matricula;   -- desempate pela matrícula
SELECT * FROM funcionarios ORDER BY nome, matricula DESC; -- DESC vale só para matricula
```

Também dá para ordenar pela **posição** da coluna no SELECT (1ª, 2ª…):

```sql
SELECT * FROM funcionarios ORDER BY 4;           -- 4ª coluna = sobrenome
SELECT * FROM funcionarios ORDER BY 3, 4, 2;     -- nome, sobrenome, matricula
SELECT * FROM funcionarios ORDER BY 4 DESC, nome DESC, 2 ASC;
```

> Ordenar por número é prático, mas frágil: se mudar as colunas do SELECT, a ordenação muda.

Com JOIN, qualifique a coluna:

```sql
SELECT aluno.id   AS aluno_id,
       aluno.nome AS "Nome do aluno",
       curso.id   AS curso_id,
       curso.nome AS "Nome do curso"
  FROM aluno
  JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
  JOIN curso       ON curso.id = aluno_curso.curso_id
 ORDER BY curso.nome, aluno.nome DESC;
```

## 6.2 LIMIT e OFFSET — paginação

```sql
SELECT * FROM funcionarios LIMIT 5;                          -- só 5 linhas
SELECT * FROM funcionarios ORDER BY nome LIMIT 5;            -- os 5 primeiros por nome
SELECT * FROM funcionarios ORDER BY id LIMIT 5 OFFSET 3;     -- pula 3, traz 5
```

Paginação: página `p` (começando em 1) com `n` itens por página →
`LIMIT n OFFSET (p - 1) * n`. Sempre use `ORDER BY` junto, senão as páginas ficam inconsistentes.

## 6.3 Funções de agregação

Transformam **várias linhas em um único valor**:

| Função | Retorna |
|---|---|
| `COUNT(coluna)` | quantidade de valores **não nulos** |
| `COUNT(*)` | quantidade de linhas |
| `SUM(coluna)` | soma |
| `MAX(coluna)` | maior valor |
| `MIN(coluna)` | menor valor |
| `AVG(coluna)` | média |

```sql
SELECT COUNT(id),
       SUM(id),
       MAX(id),
       MIN(id),
       ROUND(AVG(id), 0)        -- ROUND(valor, casas_decimais)
  FROM funcionarios;
```

Todas as agregações (exceto `COUNT(*)`) **ignoram `NULL`**.

## 6.4 DISTINCT — eliminar repetidos

```sql
SELECT nome FROM funcionarios ORDER BY nome;                    -- Diogo aparece 3x
SELECT DISTINCT nome FROM funcionarios ORDER BY nome;           -- Diogo 1x
SELECT DISTINCT nome, sobrenome FROM funcionarios ORDER BY nome; -- combinação única
SELECT COUNT(DISTINCT nome) FROM funcionarios;                  -- quantos nomes diferentes
```

## 6.5 GROUP BY — agregar por grupo

`GROUP BY` junta as linhas com o mesmo valor e aplica a agregação **em cada grupo**:

```sql
SELECT nome, sobrenome, COUNT(id)
  FROM funcionarios
 GROUP BY nome, sobrenome
 ORDER BY nome;

SELECT nome, sobrenome, COUNT(id)
  FROM funcionarios
 GROUP BY 1, 2            -- por posição
 ORDER BY nome;
```

> **Regra de ouro:** toda coluna do SELECT que **não** está dentro de uma função de agregação
> precisa estar no `GROUP BY`. Senão: `ERROR: column "x" must appear in the GROUP BY clause…`

Com JOIN — quantos alunos por curso:

```sql
SELECT curso.nome, COUNT(aluno.id)
  FROM aluno
  JOIN aluno_curso ON aluno.id = aluno_curso.aluno_id
  JOIN curso       ON curso.id = aluno_curso.curso_id
 GROUP BY 1
 ORDER BY 1;
```

Com `INNER JOIN`, cursos sem alunos somem. Para que apareçam com **0**, use `LEFT JOIN`
partindo de `curso` e conte uma coluna da tabela da direita (`COUNT(aluno.id)`, não `COUNT(*)`):

```sql
SELECT curso.nome, COUNT(aluno.id)
  FROM curso
  LEFT JOIN aluno_curso ON aluno_curso.curso_id = curso.id
  LEFT JOIN aluno       ON aluno.id = aluno_curso.aluno_id
 GROUP BY 1;
```

## 6.6 HAVING — filtrar grupos

- `WHERE` filtra **linhas antes** de agrupar (não pode usar `COUNT`, `SUM`...).
- `HAVING` filtra **grupos depois** de agrupar (pode usar agregações).

```sql
-- cursos com pelo menos um aluno
SELECT curso.nome, COUNT(aluno.id)
  FROM curso
  LEFT JOIN aluno_curso ON aluno_curso.curso_id = curso.id
  LEFT JOIN aluno       ON aluno.id = aluno_curso.aluno_id
 GROUP BY 1
HAVING COUNT(aluno.id) > 0;

-- nomes repetidos entre os funcionários
SELECT nome, COUNT(id)
  FROM funcionarios
 GROUP BY nome
HAVING COUNT(id) > 1;

-- nomes que aparecem uma única vez
SELECT nome, COUNT(id)
  FROM funcionarios
 GROUP BY nome
HAVING COUNT(id) = 1;
```

## 6.7 A ordem em que o banco executa um SELECT

Você **escreve** numa ordem, mas o banco **processa** em outra:

| Escrita | Execução lógica |
|---|---|
| 1. `SELECT` | 1. `FROM` / `JOIN` — monta as linhas |
| 2. `FROM` / `JOIN` | 2. `WHERE` — filtra linhas |
| 3. `WHERE` | 3. `GROUP BY` — forma grupos |
| 4. `GROUP BY` | 4. `HAVING` — filtra grupos |
| 5. `HAVING` | 5. `SELECT` — calcula colunas e apelidos |
| 6. `ORDER BY` | 6. `DISTINCT` |
| 7. `LIMIT/OFFSET` | 7. `ORDER BY` → 8. `LIMIT/OFFSET` |

Isso explica por que um apelido criado no `SELECT` **pode** ser usado no `ORDER BY`,
mas **não** no `WHERE` (o `WHERE` roda antes do apelido existir).

## Exercícios

1. Liste os funcionários ordenados por sobrenome (Z→A) e, em caso de empate, por matrícula.
2. Mostre a 2ª página de funcionários, com 3 por página, ordenados por `id`.
3. Quantos funcionários existem? E quantos sobrenomes diferentes?
4. Quantos funcionários há por nome? Mostre do mais frequente ao menos frequente.
5. Quais sobrenomes aparecem mais de uma vez?
6. Quantos cursos cada aluno faz? Inclua alunos sem curso (com 0).
7. Por que esta consulta dá erro? `SELECT nome, COUNT(id) FROM funcionarios WHERE COUNT(id) > 1 GROUP BY nome;`

<details><summary>Gabarito</summary>

```sql
-- 1
SELECT * FROM funcionarios ORDER BY sobrenome DESC, matricula;
-- 2
SELECT * FROM funcionarios ORDER BY id LIMIT 3 OFFSET 3;
-- 3
SELECT COUNT(*) AS total, COUNT(DISTINCT sobrenome) AS sobrenomes FROM funcionarios;
-- 4
SELECT nome, COUNT(*) AS quantidade
  FROM funcionarios
 GROUP BY nome
 ORDER BY quantidade DESC, nome;
-- 5
SELECT sobrenome, COUNT(*)
  FROM funcionarios
 GROUP BY sobrenome
HAVING COUNT(*) > 1;
-- 6
SELECT aluno.nome, COUNT(aluno_curso.curso_id) AS qtd_cursos
  FROM aluno
  LEFT JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
 GROUP BY aluno.id, aluno.nome
 ORDER BY qtd_cursos DESC;
```

7. Agregações não podem ficar no `WHERE`, porque o `WHERE` é executado antes do agrupamento.
O correto é `... GROUP BY nome HAVING COUNT(id) > 1;`

</details>

Próximo: [Módulo 7 — Projeto final](07-projeto-final.md)
