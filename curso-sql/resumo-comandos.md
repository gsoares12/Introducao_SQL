# Resumo de comandos SQL (PostgreSQL)

## Banco de dados
```sql
CREATE DATABASE nome;
DROP DATABASE [IF EXISTS] nome;
SHOW data_directory;                  -- onde os arquivos ficam no disco
```

## Tabelas (DDL)
```sql
CREATE TABLE [IF NOT EXISTS] tabela (
    id     SERIAL PRIMARY KEY,
    coluna TIPO [NOT NULL] [UNIQUE] [DEFAULT valor] [CHECK (condição)],
    outra_id INTEGER REFERENCES outra (id) [ON DELETE CASCADE|RESTRICT|SET NULL]
                                           [ON UPDATE CASCADE|RESTRICT|SET NULL],
    PRIMARY KEY (col1, col2),                       -- chave composta
    FOREIGN KEY (col) REFERENCES outra (id)         -- FK em formato de tabela
);
ALTER TABLE tabela ADD COLUMN col TIPO;
ALTER TABLE tabela DROP COLUMN col;
ALTER TABLE tabela RENAME COLUMN antiga TO nova;
ALTER TABLE tabela RENAME TO novo_nome;
DROP TABLE [IF EXISTS] tabela;
TRUNCATE TABLE tabela;
```

## Dados (DML)
```sql
INSERT INTO tabela (col1, col2) VALUES (v1, v2), (v3, v4) [RETURNING id];
UPDATE tabela SET col1 = v1, col2 = v2 WHERE condição;   -- ⚠️ sem WHERE = todas
DELETE FROM tabela WHERE condição;                       -- ⚠️ sem WHERE = todas
```

## Consulta (DQL) — ordem de escrita
```sql
SELECT [DISTINCT] col, AGREGACAO(col) AS apelido
  FROM tabela t
  [INNER|LEFT|RIGHT|FULL] JOIN outra o ON o.id = t.outra_id
  [CROSS JOIN outra]
 WHERE condição_de_linha
 GROUP BY col
HAVING condição_de_grupo
 ORDER BY col [ASC|DESC], ...
 LIMIT n OFFSET m;
```

## Operadores do WHERE
| | |
|---|---|
| `=  <>  !=  >  >=  <  <=` | comparação |
| `BETWEEN a AND b` | intervalo inclusivo |
| `IN (a, b)` / `NOT IN` | lista |
| `LIKE 'D%'` / `NOT LIKE` / `ILIKE` | padrão (`%` = vários, `_` = um) |
| `IS NULL` / `IS NOT NULL` | nulos |
| `AND  OR  NOT  ( )` | lógica |

## Agregações
`COUNT(*)`, `COUNT(col)`, `COUNT(DISTINCT col)`, `SUM`, `AVG`, `MIN`, `MAX`, `ROUND(x, n)`

## Transações
```sql
BEGIN;  ...  COMMIT;     -- confirma
BEGIN;  ...  ROLLBACK;   -- desfaz
```

## psql
`\l` bancos · `\c banco` conectar · `\dt` tabelas · `\d tabela` estrutura ·
`\i arquivo.sql` executar arquivo · `\x` modo vertical · `\q` sair

## Tipos mais usados
`SERIAL`, `INTEGER`, `BIGINT`, `NUMERIC(p,s)`, `REAL`, `VARCHAR(n)`, `CHAR(n)`, `TEXT`,
`BOOLEAN`, `DATE`, `TIME`, `TIMESTAMP`
