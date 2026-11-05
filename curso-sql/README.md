# Curso de SQL com PostgreSQL — do zero aos relatórios

Este curso foi montado a partir dos scripts das aulas que estão na pasta acima
(`Aula01-atividade03.sql` … `Aula06-atividade06.sql`). Cada módulo explica os
conceitos, mostra os comandos usados nas aulas, aponta os erros mais comuns e
termina com **exercícios práticos com gabarito**.

## Como estudar

1. Comece pelo **Módulo 0**: ele instala o PostgreSQL, explica *onde* o banco é criado
   no seu computador e como abrir uma janela para digitar SQL.
2. Siga os módulos em ordem. Cada um depende das tabelas criadas no anterior.
3. Digite os comandos você mesmo (não copie e cole tudo). Errar e ler a mensagem de erro
   faz parte do aprendizado.
4. Se o banco ficar "bagunçado", rode [scripts/reset-banco.sql](scripts/reset-banco.sql)
   para recriar todas as tabelas com dados de exemplo.

## Conteúdo

| Módulo | Tema | Aulas originais |
|---|---|---|
| [0 — Ambiente](00-ambiente.md) | O que é um SGBD, instalar PostgreSQL, pgAdmin, psql, onde os dados ficam | — |
| [1 — Bancos e tabelas](01-bancos-e-tabelas.md) | `CREATE/DROP DATABASE`, tipos de dados, `CREATE TABLE` | Aula 01 |
| [2 — CRUD](02-crud.md) | `INSERT`, `SELECT`, `UPDATE`, `DELETE` | Aula 02 |
| [3 — Consultas e filtros](03-consultas-e-filtros.md) | colunas, apelidos (`AS`), `WHERE`, `LIKE`, `NULL`, `BETWEEN`, `AND/OR` | Aula 03 |
| [4 — Restrições, relacionamentos e JOINs](04-relacionamentos-e-joins.md) | `NOT NULL`, `UNIQUE`, `PRIMARY KEY`, `SERIAL`, `FOREIGN KEY`, `JOIN`s | Aula 04 |
| [5 — Integridade referencial](05-integridade-cascade.md) | `ON DELETE`/`ON UPDATE` `CASCADE`/`RESTRICT`/`SET NULL` | Aula 05 |
| [6 — Ordenação, paginação e agrupamento](06-ordenacao-e-agrupamento.md) | `ORDER BY`, `LIMIT/OFFSET`, `COUNT/SUM/AVG…`, `DISTINCT`, `GROUP BY`, `HAVING` | Aula 06 |
| [7 — Projeto final](07-projeto-final.md) | Modelar e consultar um banco do zero | — |
| [Resumo de comandos](resumo-comandos.md) | Folha de consulta rápida | — |

## Vocabulário mínimo

- **SQL** (*Structured Query Language*): a linguagem usada para conversar com bancos de dados relacionais.
- **SGBD**: o programa que guarda os dados e executa o SQL. Aqui usamos o **PostgreSQL**.
- **Banco de dados (database)**: um conjunto isolado de tabelas. Ex.: `alura`.
- **Tabela**: uma "planilha" com colunas fixas e tipadas. Ex.: `aluno`.
- **Coluna (campo)**: um atributo. Ex.: `nome`, `idade`.
- **Linha (registro, tupla)**: um item da tabela. Ex.: o aluno "Diogo".

As categorias de comandos SQL:

| Sigla | Significado | Comandos |
|---|---|---|
| **DDL** | Data Definition Language — define a *estrutura* | `CREATE`, `ALTER`, `DROP` |
| **DML** | Data Manipulation Language — mexe nos *dados* | `INSERT`, `UPDATE`, `DELETE` |
| **DQL** | Data Query Language — *consulta* dados | `SELECT` |
| **DCL** | Data Control Language — *permissões* | `GRANT`, `REVOKE` |
| **TCL** | Transaction Control Language — *transações* | `BEGIN`, `COMMIT`, `ROLLBACK` |
