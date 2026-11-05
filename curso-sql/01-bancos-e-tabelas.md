# Módulo 1 — Criando bancos e tabelas (DDL)

Baseado em `Aula01-atividade03.sql` e `Aula01-atividade05.sql`.

## 1.1 Criar e apagar um banco

Conecte-se no banco `postgres` (o padrão) e rode:

```sql
CREATE DATABASE alura;

CREATE DATABASE teste;
DROP DATABASE teste;
```

- `CREATE DATABASE nome;` cria um banco vazio (uma nova pasta em `data\base\`, ver Módulo 0).
- `DROP DATABASE nome;` **apaga o banco inteiro e todos os dados**, sem pedir confirmação.
  Não existe "lixeira".

Detalhes úteis:

```sql
-- Não dá erro se já existir / se não existir
DROP DATABASE IF EXISTS teste;

-- Você não consegue apagar o banco em que está conectado.
-- Conecte em "postgres" para apagar "alura".
```

> No PostgreSQL não existe `CREATE DATABASE IF NOT EXISTS`. Para tabelas, existe:
> `CREATE TABLE IF NOT EXISTS`.

**A partir daqui, todos os comandos devem ser executados conectados ao banco `alura`.**
(No pgAdmin: *Refresh* em *Databases* → botão direito em `alura` → *Query Tool*.
No psql: `\c alura`.)

## 1.2 Tipos de dados

Toda coluna tem um tipo. O tipo define o que pode ser guardado e quanto espaço ocupa.

| Tipo | Para quê | Exemplo de valor |
|---|---|---|
| `SERIAL` | inteiro que **se auto-incrementa** (1, 2, 3…) — ideal para `id` | gerado automaticamente |
| `INTEGER` (`INT`) | números inteiros (±2,1 bilhões) | `35` |
| `BIGINT` | inteiros muito grandes | `9000000000` |
| `NUMERIC(p,s)` | decimal **exato** — use para dinheiro | `NUMERIC(10,2)` → `12345678.90` |
| `REAL` / `DOUBLE PRECISION` | decimal aproximado (ponto flutuante) | `1.81` |
| `VARCHAR(n)` | texto com tamanho máximo `n` | `'Diogo'` |
| `CHAR(n)` | texto de tamanho **fixo** `n` (completa com espaços) | `CHAR(11)` → CPF |
| `TEXT` | texto sem limite prático | observações longas |
| `BOOLEAN` | verdadeiro/falso | `TRUE`, `FALSE` |
| `DATE` | data | `'1984-08-27'` |
| `TIME` | hora | `'17:30:00'` |
| `TIMESTAMP` | data + hora | `'2020-02-08 12:32:45'` |

Por que `NUMERIC` para dinheiro e não `REAL`? Porque `REAL` é aproximado:
`SELECT 0.1::REAL + 0.2::REAL;` não dá exatamente `0.3`. Em `NUMERIC(10,2)`,
`10` é o total de dígitos e `2` são as casas decimais (máximo `99999999.99`).

Datas sempre no formato **ISO**: `'AAAA-MM-DD'`, entre aspas simples.

## 1.3 Criar uma tabela

```sql
CREATE TABLE aluno
(
    id              SERIAL,
    nome            VARCHAR(255),
    cpf             CHAR(11),
    observacao      TEXT,
    idade           INTEGER,
    dinheiro        NUMERIC(10,2),
    altura          REAL,
    ativo           BOOLEAN,
    data_nascimento DATE,
    hora_aula       TIME,
    matriculado_em  TIMESTAMP
);

SELECT * FROM aluno;   -- tabela vazia, mas mostra as colunas
```

Anatomia: `CREATE TABLE nome ( coluna tipo [restrições], ... );`
- Colunas separadas por vírgula; **sem vírgula** depois da última.
- Nomes de tabelas e colunas: minúsculas, sem acento, com `_` (convenção *snake_case*).
  O PostgreSQL converte nomes sem aspas para minúsculo: `Aluno` e `aluno` são iguais.

## 1.4 Alterar e apagar tabelas

As aulas usam `DROP TABLE` e recriam a tabela. Também é possível alterar sem perder dados:

```sql
ALTER TABLE aluno ADD COLUMN email VARCHAR(255);       -- adiciona coluna
ALTER TABLE aluno RENAME COLUMN email TO email_contato; -- renomeia
ALTER TABLE aluno DROP COLUMN email_contato;            -- remove coluna
ALTER TABLE aluno RENAME TO estudante;                  -- renomeia a tabela
ALTER TABLE estudante RENAME TO aluno;

DROP TABLE nome_da_tabela;            -- apaga estrutura + dados
DROP TABLE IF EXISTS nome_da_tabela;  -- sem erro se não existir
TRUNCATE TABLE nome_da_tabela;        -- apaga só os dados, mantém a estrutura
```

Ver a estrutura de uma tabela: no psql `\d aluno`; no pgAdmin *Schemas → public → Tables →
aluno → Columns*.

## Exercícios

1. Crie um banco chamado `loja` e depois apague-o.
2. No banco `alura`, crie a tabela `professor` com: `id` auto-incremento, `nome` (até 100
   caracteres), `salario` (dinheiro), `data_admissao` (data) e `efetivo` (sim/não).
3. Adicione a coluna `email` em `professor`.
4. Qual tipo você usaria para: CEP? Quantidade em estoque? Preço? Biografia? Horário de abertura?
5. Apague a tabela `professor`.

<details><summary>Gabarito</summary>

```sql
-- 1 (conectado em postgres)
CREATE DATABASE loja;
DROP DATABASE loja;

-- 2 (conectado em alura)
CREATE TABLE professor (
    id            SERIAL,
    nome          VARCHAR(100),
    salario       NUMERIC(10,2),
    data_admissao DATE,
    efetivo       BOOLEAN
);

-- 3
ALTER TABLE professor ADD COLUMN email VARCHAR(255);

-- 5
DROP TABLE professor;
```

4. CEP: `CHAR(8)` (é texto — pode começar com zero e não se faz conta com ele);
estoque: `INTEGER`; preço: `NUMERIC(10,2)`; biografia: `TEXT`; horário: `TIME`.

</details>

Próximo: [Módulo 2 — CRUD](02-crud.md)
