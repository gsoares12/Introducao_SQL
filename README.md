# Introdução ao SQL

Este repositório reúne materiais e exercícios de um curso introdutório de SQL com
PostgreSQL. Ao longo do curso, são apresentados os fundamentos de bancos de dados
relacionais e a prática de criar estruturas, manipular informações e elaborar consultas
para responder a perguntas sobre os dados.

## O que foi estudado

- **Ambiente e bancos de dados:** conceitos de SGBD, PostgreSQL, pgAdmin e psql,
  conexão com um banco e organização de schemas, tabelas, linhas e colunas.
- **Criação de estruturas:** criação e alteração de bancos e tabelas, tipos de dados
  e comandos DDL, como `CREATE`, `ALTER` e `DROP`.
- **Manipulação de dados (CRUD):** inclusão, consulta, atualização e remoção de registros
  com `INSERT`, `SELECT`, `UPDATE` e `DELETE`, além do uso de transações.
- **Consultas e filtros:** seleção de colunas, apelidos, condições com `WHERE`, operadores
  lógicos e comparativos, padrões com `LIKE` e tratamento de valores `NULL`.
- **Restrições e relacionamentos:** chaves primárias e estrangeiras, integridade
  referencial, relacionamentos entre tabelas e consultas com `JOIN`.
- **Integridade referencial:** efeitos de `CASCADE`, `RESTRICT` e outras ações ao excluir
  ou atualizar registros relacionados.
- **Relatórios:** ordenação e paginação com `ORDER BY`, `LIMIT` e `OFFSET`, além de
  agregações, `DISTINCT`, `GROUP BY` e `HAVING`.
- **Projeto prático:** modelagem de um banco de biblioteca e consultas que combinam os
  conceitos estudados.

## Material do curso

O conteúdo organizado por módulos, com explicações, exemplos e exercícios, está na pasta
[curso-sql](curso-sql/README.md). O curso pode ser seguido nesta ordem:

Os [slides das aulas](https://docs.google.com/presentation/d/1ln0HcXGosq8Yt63W5J9fM8yioo-HbLkm/edit?slide=id.p2#slide=id.p2) também estão disponíveis publicamente no Google Drive.

1. [Preparação do ambiente](curso-sql/00-ambiente.md)
2. [Bancos e tabelas](curso-sql/01-bancos-e-tabelas.md)
3. [CRUD](curso-sql/02-crud.md)
4. [Consultas e filtros](curso-sql/03-consultas-e-filtros.md)
5. [Relacionamentos e JOINs](curso-sql/04-relacionamentos-e-joins.md)
6. [Integridade referencial](curso-sql/05-integridade-cascade.md)
7. [Ordenação e agrupamento](curso-sql/06-ordenacao-e-agrupamento.md)
8. [Projeto final](curso-sql/07-projeto-final.md)

Os arquivos `AulaXX-atividadeYY.sql` contêm exercícios práticos das aulas originais.
Para revisar a sintaxe, consulte também o [resumo de comandos SQL](curso-sql/resumo-comandos.md).
