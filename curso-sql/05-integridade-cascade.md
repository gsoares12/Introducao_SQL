# Módulo 5 — Integridade referencial: CASCADE, RESTRICT e cia.

Baseado em `Aula05-atividade01.sql` e `Aula05-atividade03.sql`.

## 5.1 O problema

Com a FK do Módulo 4, tente apagar um aluno que está matriculado:

```sql
DELETE FROM aluno WHERE id = 1;
-- ERROR: update or delete on table "aluno" violates foreign key constraint
--        "aluno_curso_aluno_id_fkey" on table "aluno_curso"
```

O banco **impede** que a matrícula fique "órfã" (apontando para um aluno que não existe).
Isso é **integridade referencial**. O mesmo vale para alterar o `id` de um aluno referenciado.

## 5.2 As opções de ON DELETE / ON UPDATE

| Opção | O que acontece com as linhas filhas (`aluno_curso`) quando o pai (`aluno`) é apagado/alterado |
|---|---|
| `NO ACTION` (**padrão**) | bloqueia a operação com erro (verificado ao fim do comando) |
| `RESTRICT` | bloqueia a operação com erro (verificado imediatamente) |
| `CASCADE` | propaga: apaga as filhas (DELETE) ou atualiza o id nelas (UPDATE) |
| `SET NULL` | coloca `NULL` na coluna da FK |
| `SET DEFAULT` | coloca o valor `DEFAULT` da coluna |

## 5.3 ON DELETE CASCADE

```sql
DROP TABLE aluno_curso;

CREATE TABLE aluno_curso (
    aluno_id INTEGER,
    curso_id INTEGER,
    PRIMARY KEY (aluno_id, curso_id),

    FOREIGN KEY (aluno_id) REFERENCES aluno (id)
        ON DELETE CASCADE,

    FOREIGN KEY (curso_id) REFERENCES curso (id)
);

INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (1, 1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (2, 1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (3, 1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (1, 3);

DELETE FROM aluno WHERE id = 1;    -- agora funciona
SELECT * FROM aluno_curso;         -- as matrículas do aluno 1 sumiram junto
```

## 5.4 ON UPDATE CASCADE

```sql
UPDATE aluno SET id = 10 WHERE id = 2;   -- ❌ erro: id 2 é referenciado (só temos ON DELETE)

DROP TABLE aluno_curso;

CREATE TABLE aluno_curso (
    aluno_id INTEGER,
    curso_id INTEGER,
    PRIMARY KEY (aluno_id, curso_id),

    FOREIGN KEY (aluno_id) REFERENCES aluno (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (curso_id) REFERENCES curso (id)
);

INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (2, 1);
INSERT INTO aluno_curso (aluno_id, curso_id) VALUES (3, 1);

UPDATE aluno SET id = 10 WHERE id = 2;   -- ✅
SELECT * FROM aluno_curso;               -- a matrícula agora aponta para 10
```

## 5.5 Quando usar o quê?

- **CASCADE no DELETE**: quando a filha não faz sentido sem o pai
  (itens de um pedido, matrículas de um aluno excluído).
- **RESTRICT / NO ACTION**: quando apagar o pai por engano seria grave
  (não deixar apagar um cliente que tem notas fiscais).
- **SET NULL**: quando a relação é opcional (curso sem categoria definida).
- **ON UPDATE CASCADE**: útil, mas o ideal é **nunca alterar chaves primárias**. Com `SERIAL`
  isso raramente é necessário.

> ⚠️ CASCADE é poderoso: um único `DELETE` pode apagar muitas linhas em várias tabelas.

## 5.6 Erros didáticos presentes nos scripts originais

Ao revisar os arquivos das aulas, repare em três armadilhas reais:

1. `Aula05-atividade01.sql`: `DELETE FROM alunos WHERE id = 1;` → a tabela é `aluno`
   (singular). Erro: `relation "alunos" does not exist`.
2. `Aula05-atividade03.sql`: o primeiro `UPDATE aluno SET id = 10 WHERE id = 2` está **sem
   `;`**, então ele "gruda" no `SELECT` seguinte e gera erro de sintaxe ao executar o arquivo todo.
3. `Aula03-atividade01.sql`: `nome as Nome do Aluno` sem aspas duplas → erro de sintaxe
   (proposital, para mostrar a necessidade das aspas).

## Exercícios

1. Recrie `aluno_curso` com `ON DELETE CASCADE` também na FK de `curso_id`.
   Apague um curso e verifique o que aconteceu com as matrículas.
2. Crie as tabelas `pedido (id SERIAL PK, cliente VARCHAR(100))` e
   `item_pedido (id SERIAL PK, pedido_id INTEGER, produto VARCHAR(100))` em que apagar um
   pedido apaga seus itens.
3. Explique a diferença entre `DROP TABLE aluno_curso`, `DELETE FROM aluno_curso` e
   `TRUNCATE aluno_curso`.

<details><summary>Gabarito</summary>

```sql
-- 1
DROP TABLE aluno_curso;
CREATE TABLE aluno_curso (
    aluno_id INTEGER,
    curso_id INTEGER,
    PRIMARY KEY (aluno_id, curso_id),
    FOREIGN KEY (aluno_id) REFERENCES aluno (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (curso_id) REFERENCES curso (id) ON DELETE CASCADE
);
INSERT INTO aluno_curso VALUES (3, 1);   -- ajuste para ids existentes
DELETE FROM curso WHERE id = 1;
SELECT * FROM aluno_curso;               -- matrículas do curso 1 removidas

-- 2
CREATE TABLE pedido (
    id      SERIAL PRIMARY KEY,
    cliente VARCHAR(100)
);
CREATE TABLE item_pedido (
    id        SERIAL PRIMARY KEY,
    pedido_id INTEGER REFERENCES pedido (id) ON DELETE CASCADE,
    produto   VARCHAR(100)
);
```

3. `DROP TABLE` remove a tabela inteira (estrutura + dados). `DELETE FROM` remove linhas
(todas, se não houver `WHERE`), linha a linha, e pode ser filtrado. `TRUNCATE` esvazia a
tabela toda de uma vez (mais rápido), mantendo a estrutura; não aceita `WHERE`.

</details>

Próximo: [Módulo 6 — Ordenação, paginação e agrupamento](06-ordenacao-e-agrupamento.md)
