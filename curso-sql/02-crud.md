# Módulo 2 — CRUD: inserir, ler, atualizar e apagar (DML)

Baseado em `Aula02-atividade01.sql`, `Aula02-atividade03.sql` e `Aula02-atividade05.sql`.

**CRUD** = **C**reate (`INSERT`), **R**ead (`SELECT`), **U**pdate (`UPDATE`), **D**elete (`DELETE`).

Pré-requisito: tabela `aluno` do Módulo 1 criada no banco `alura`.

## 2.1 INSERT — inserir dados

```sql
INSERT INTO aluno (
    nome, cpf, observacao, idade, dinheiro, altura,
    ativo, data_nascimento, hora_aula, matriculado_em
) VALUES (
    'Diogo', '12345678901', 'Lorem ipsum dolor sit amet...', 35, 100.50, 1.81,
    TRUE, '1984-08-27', '17:30:00', '2020-02-08 12:32:45'
);
```

Regras:
- A lista de colunas e a lista de `VALUES` têm de ter **a mesma quantidade e a mesma ordem**.
- Textos e datas vão entre **aspas simples** `'...'`. Números e `TRUE/FALSE`, sem aspas.
- Decimal usa **ponto**: `100.50`, nunca `100,50`.
- Não informamos o `id`: por ser `SERIAL`, o banco gera sozinho.
- Colunas omitidas recebem `NULL` (ausência de valor) ou o `DEFAULT` da coluna.
- Texto com apóstrofo: duplique a aspa → `'D''Ávila'`.

Inserir várias linhas de uma vez:

```sql
INSERT INTO aluno (nome, idade) VALUES
    ('Ana', 22),
    ('Bruno', 30),
    ('Carla', 27);
```

Ver o que foi gerado já no INSERT (recurso do PostgreSQL):

```sql
INSERT INTO aluno (nome) VALUES ('Teste') RETURNING id, nome;
```

## 2.2 SELECT — ler dados

```sql
SELECT * FROM aluno;               -- todas as colunas, todas as linhas
SELECT * FROM aluno WHERE id = 1;  -- só a linha com id 1
```

O `SELECT` é aprofundado no Módulo 3.

## 2.3 UPDATE — alterar dados

```sql
SELECT * FROM aluno WHERE id = 1;   -- 1º: confira QUEM será alterado

UPDATE aluno
   SET nome = 'Nico',
       cpf = '10987654321',
       observacao = 'Teste',
       idade = 38,
       dinheiro = 15.32,
       altura = 1.90,
       ativo = FALSE,
       data_nascimento = '1980-01-15',
       hora_aula = '13:00:00',
       matriculado_em = '2020-01-02 15:00:00'
 WHERE id = 1;
```

- `SET coluna = valor`, várias separadas por vírgula.
- Pode usar o valor atual: `UPDATE aluno SET idade = idade + 1 WHERE id = 1;`

> ⚠️ **UPDATE sem WHERE altera TODAS as linhas da tabela.**
> Hábito profissional: escreva primeiro o `SELECT ... WHERE ...`, confira o resultado e só
> então troque o `SELECT *` por `UPDATE ... SET ...` mantendo o mesmo `WHERE`.

## 2.4 DELETE — apagar dados

```sql
SELECT * FROM aluno WHERE nome = 'Nico';   -- confira antes

DELETE FROM aluno WHERE nome = 'Nico';
```

> ⚠️ **DELETE sem WHERE apaga TODAS as linhas.**

Note que filtrar por `nome` pode pegar mais pessoas do que você imagina (homônimos).
Prefira filtrar pela chave: `WHERE id = 1`.

## 2.5 Rede de segurança: transações

Você pode "testar" uma alteração e desfazê-la:

```sql
BEGIN;                         -- inicia uma transação
DELETE FROM aluno;             -- ops, sem WHERE!
SELECT * FROM aluno;           -- vazio...
ROLLBACK;                      -- desfaz tudo desde o BEGIN
SELECT * FROM aluno;           -- os dados voltaram
```

Se estiver tudo certo, use `COMMIT;` no lugar de `ROLLBACK;` para confirmar.
Sem `BEGIN`, cada comando é confirmado automaticamente (*autocommit*).

## Exercícios

Use a tabela `aluno`.

1. Insira 3 alunos de uma vez, informando nome, idade e se está ativo.
2. Liste todos os alunos.
3. Aumente em 1 ano a idade de **apenas um** deles (use o `id`).
4. Desative (ativo = false) um aluno específico.
5. Dentro de uma transação, apague todos os alunos, confira que a tabela está vazia e desfaça.
6. Apague definitivamente um aluno pelo `id`.

<details><summary>Gabarito</summary>

```sql
-- 1
INSERT INTO aluno (nome, idade, ativo) VALUES
    ('Marina', 25, TRUE),
    ('Pedro', 31, TRUE),
    ('Lucas', 19, FALSE);

-- 2
SELECT * FROM aluno;

-- 3 (use um id que exista na sua tabela)
SELECT * FROM aluno WHERE id = 2;
UPDATE aluno SET idade = idade + 1 WHERE id = 2;

-- 4
UPDATE aluno SET ativo = FALSE WHERE id = 3;

-- 5
BEGIN;
DELETE FROM aluno;
SELECT * FROM aluno;
ROLLBACK;

-- 6
DELETE FROM aluno WHERE id = 4;
```

</details>

Próximo: [Módulo 3 — Consultas e filtros](03-consultas-e-filtros.md)
