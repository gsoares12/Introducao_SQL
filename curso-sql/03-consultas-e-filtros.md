# Módulo 3 — Consultas e filtros

Baseado em `Aula03-atividade01.sql`, `03`, `05` e `07`.

Prepare dados para praticar:

```sql
INSERT INTO aluno (nome, cpf, idade, ativo) VALUES ('Diogo', '12345678901', 35, TRUE);
INSERT INTO aluno (nome) VALUES ('Vinicius Dias');
INSERT INTO aluno (nome) VALUES ('Nico Steppat');
INSERT INTO aluno (nome) VALUES ('João Roberto');
INSERT INTO aluno (nome) VALUES ('Diego');
```

## 3.1 Escolhendo colunas

```sql
SELECT * FROM aluno;                          -- todas
SELECT nome FROM aluno;                       -- só uma
SELECT nome, idade, matriculado_em FROM aluno; -- várias, na ordem que você quiser
```

> Em sistemas reais, evite `SELECT *`: traga só as colunas de que precisa.

## 3.2 Apelidos (alias) com AS

```sql
SELECT nome,
       idade,
       matriculado_em AS quando_se_matriculou
  FROM aluno;

SELECT nome AS "Nome do Aluno",      -- com espaço/maiúsculas: aspas DUPLAS
       idade
  FROM aluno;

SELECT nome AS Nome do Aluno FROM aluno;   -- ❌ ERRO de sintaxe (espaço sem aspas)
```

**Aspas simples × duplas** (fonte de erro muito comum):
- `'texto'` → **valor** (string). Ex.: `WHERE nome = 'Diogo'`.
- `"Nome"` → **identificador** (nome de coluna/tabela/apelido).

## 3.3 WHERE — filtrando linhas

### Comparação

| Operador | Significado |
|---|---|
| `=` | igual |
| `<>` ou `!=` | diferente |
| `>` `>=` `<` `<=` | maior, maior ou igual, menor, menor ou igual |
| `BETWEEN a AND b` | entre `a` e `b`, **incluindo** os extremos |
| `IN (a, b, c)` | igual a qualquer item da lista |

```sql
SELECT * FROM aluno WHERE nome = 'Diogo';
SELECT * FROM aluno WHERE nome <> 'Diogo';
SELECT * FROM aluno WHERE idade >= 35;
SELECT * FROM aluno WHERE idade BETWEEN 10 AND 40;   -- 10 <= idade <= 40
SELECT * FROM aluno WHERE nome IN ('Diogo', 'Diego');
SELECT * FROM aluno WHERE ativo = TRUE;
```

A comparação de texto com `=` diferencia maiúsculas: `'diogo'` ≠ `'Diogo'`.

### LIKE — padrões de texto

| Curinga | Significa | Exemplo | Casa com |
|---|---|---|---|
| `_` | exatamente **um** caractere qualquer | `'Di_go'` | Diogo, Diego |
| `%` | **zero ou mais** caracteres | `'D%'` | tudo que começa com D |

```sql
SELECT * FROM aluno WHERE nome LIKE '_iogo';     -- 1 letra + "iogo"
SELECT * FROM aluno WHERE nome LIKE 'Di_go';     -- Diogo e Diego
SELECT * FROM aluno WHERE nome NOT LIKE 'Di_go'; -- todos menos esses
SELECT * FROM aluno WHERE nome LIKE 'D%';        -- começa com D
SELECT * FROM aluno WHERE nome LIKE '%s';        -- termina com s
SELECT * FROM aluno WHERE nome LIKE '% %';       -- tem espaço (nome composto)
SELECT * FROM aluno WHERE nome LIKE '%i%a%';     -- tem "i" e depois um "a"
SELECT * FROM aluno WHERE nome ILIKE 'diogo';    -- ILIKE: ignora maiúsc./minúsc. (PostgreSQL)
```

### NULL — a ausência de valor

`NULL` não é zero nem texto vazio: é "desconhecido". Por isso **não se compara com `=`**:

```sql
SELECT * FROM aluno WHERE cpf = NULL;      -- ❌ nunca retorna nada
SELECT * FROM aluno WHERE cpf IS NULL;     -- ✅ sem CPF
SELECT * FROM aluno WHERE cpf IS NOT NULL; -- ✅ com CPF
SELECT * FROM aluno WHERE ativo IS NULL;
```

Repare: `WHERE idade <> 36` **não** traz alunos com idade `NULL`, porque `NULL <> 36`
resulta em "desconhecido", não em verdadeiro.

Trocar `NULL` por um valor na exibição: `SELECT nome, COALESCE(cpf, 'sem cpf') FROM aluno;`

## 3.4 Combinando condições: AND, OR, NOT

- `AND`: **todas** as condições precisam ser verdadeiras.
- `OR`: **pelo menos uma** precisa ser verdadeira.
- `NOT`: inverte.

```sql
SELECT * FROM aluno
 WHERE nome LIKE 'D%'
   AND cpf IS NOT NULL;

SELECT * FROM aluno
 WHERE nome LIKE 'Diogo'
    OR nome LIKE 'Rodrigo'
    OR nome LIKE 'Nico%';

SELECT * FROM aluno
 WHERE nome LIKE '%Steppat'
   AND nome LIKE 'Nico%';
```

**Precedência:** `AND` é avaliado antes de `OR`. Use parênteses para deixar claro:

```sql
-- Ativos que se chamam Diogo ou Nico
SELECT * FROM aluno
 WHERE ativo = TRUE
   AND (nome = 'Diogo' OR nome LIKE 'Nico%');
```

Sem os parênteses, a consulta acima significaria "(ativo e Diogo) **ou** qualquer Nico".

## Exercícios

1. Liste apenas `nome` e `idade`, com os títulos "Aluno" e "Idade (anos)".
2. Alunos cujo nome termina em "o".
3. Alunos com nome composto (com espaço).
4. Alunos sem idade cadastrada.
5. Alunos com idade entre 18 e 30 **ou** sem CPF.
6. Alunos cujo nome tem exatamente 5 letras.
7. Alunos ativos cujo nome começa com "D" ou com "N".

<details><summary>Gabarito</summary>

```sql
-- 1
SELECT nome AS "Aluno", idade AS "Idade (anos)" FROM aluno;
-- 2
SELECT * FROM aluno WHERE nome LIKE '%o';
-- 3
SELECT * FROM aluno WHERE nome LIKE '% %';
-- 4
SELECT * FROM aluno WHERE idade IS NULL;
-- 5
SELECT * FROM aluno WHERE idade BETWEEN 18 AND 30 OR cpf IS NULL;
-- 6
SELECT * FROM aluno WHERE nome LIKE '_____';
-- 7
SELECT * FROM aluno
 WHERE ativo = TRUE
   AND (nome LIKE 'D%' OR nome LIKE 'N%');
```

</details>

Próximo: [Módulo 4 — Restrições, relacionamentos e JOINs](04-relacionamentos-e-joins.md)
