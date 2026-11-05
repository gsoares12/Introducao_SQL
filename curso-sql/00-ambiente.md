# Módulo 0 — Preparando o ambiente

## 0.1 Como um banco de dados funciona

O PostgreSQL é um **servidor**: um programa que fica rodando em segundo plano no seu
computador (um *serviço* do Windows), escutando conexões na **porta 5432**.
Você não abre os arquivos do banco diretamente — você usa um **cliente** que se conecta
ao servidor e envia comandos SQL.

```
 Você ──► Cliente (pgAdmin / psql / VS Code) ──SQL──► Servidor PostgreSQL ──► Arquivos em disco
                                              ◄─resultado──
```

A hierarquia dentro do servidor:

```
Servidor (cluster)  ← uma instalação, uma porta (5432)
 └─ Banco de dados  ← ex.: postgres, alura
     └─ Schema      ← "pasta" dentro do banco; o padrão é public
         └─ Tabela  ← ex.: aluno, curso
             └─ Linhas e colunas
```

> Nas aulas nunca escrevemos o schema porque tudo vai para `public`.
> `aluno` e `public.aluno` são a mesma tabela.

## 0.2 Instalando o PostgreSQL no Windows

1. Acesse **https://www.postgresql.org/download/windows/** e clique em
   *Download the installer* (instalador da EDB).
2. Baixe a versão mais recente para Windows x86-64 e execute.
3. Durante a instalação:
   - **Componentes**: deixe marcados *PostgreSQL Server*, *pgAdmin 4* e *Command Line Tools*.
     O *Stack Builder* é opcional (pode desmarcar).
   - **Data Directory**: aceite o padrão — anote esse caminho (ver 0.4).
   - **Senha do superusuário `postgres`**: escolha uma e **anote**. Você vai usá-la sempre.
   - **Porta**: `5432` (padrão).
   - **Locale**: *Default locale* ou `Portuguese, Brazil`.
4. Conclua. O serviço `postgresql-x64-<versão>` será iniciado automaticamente.

Para conferir se o serviço está rodando, no PowerShell:

```powershell
Get-Service *postgres*
```

O `Status` deve ser `Running`. Se estiver `Stopped`: `Start-Service postgresql-x64-17`
(troque `17` pela sua versão).

### Alternativa: Docker

Se você já usa Docker, isto sobe um servidor equivalente sem instalar nada:

```powershell
docker run --name pg-curso -e POSTGRES_PASSWORD=postgres -p 5432:5432 -v pg-curso-dados:/var/lib/postgresql/data -d postgres:17
```

Usuário `postgres`, senha `postgres`, host `localhost`, porta `5432`.
Os dados ficam no volume Docker `pg-curso-dados` (sobrevivem se o container for removido).

## 0.3 Os três jeitos de escrever SQL

### a) pgAdmin 4 (interface gráfica — usado nas aulas)

1. Abra o **pgAdmin 4** pelo menu Iniciar. Ele abre no navegador ou em janela própria.
2. No painel esquerdo, expanda **Servers → PostgreSQL 17** e digite a senha do `postgres`.
3. Expanda **Databases**. Você verá o banco `postgres` (vem de fábrica).
4. Clique com o botão direito num banco → **Query Tool**. Abre um editor de SQL.
5. Digite o comando e pressione **F5** (ou o botão ▶).
   - Se houver vários comandos no editor, **selecione** o trecho desejado antes de F5;
     senão o pgAdmin executa *tudo*.
6. O resultado aparece em *Data Output*; erros e avisos em *Messages*.

> Importante: o Query Tool fica conectado a **um** banco específico (aparece no topo da aba).
> Se você criar o banco `alura` estando conectado em `postgres`, precisa abrir um **novo**
> Query Tool clicando com o botão direito em `alura` (talvez dando *Refresh* em *Databases* antes).

### b) psql (linha de comando)

Abra **SQL Shell (psql)** no menu Iniciar e aperte Enter nas perguntas (aceitando os padrões),
digitando sua senha no final. Ou, no terminal:

```powershell
& "C:\Program Files\PostgreSQL\17\bin\psql.exe" -U postgres
```

Comandos do próprio psql (começam com barra invertida, **sem** ponto e vírgula):

| Comando | O que faz |
|---|---|
| `\l` | lista os bancos |
| `\c alura` | conecta no banco `alura` |
| `\dt` | lista as tabelas do banco atual |
| `\d aluno` | mostra a estrutura da tabela `aluno` |
| `\i 'C:/caminho/arquivo.sql'` | executa um arquivo `.sql` (use `/` no caminho) |
| `\x` | alterna exibição vertical (bom para linhas largas) |
| `\q` | sai |

Comandos SQL no psql **precisam terminar com `;`** — sem ele, o psql espera mais texto
(o prompt muda de `alura=#` para `alura-#`).

> Acentos estranhos no psql do Windows? Rode `\encoding UTF8` ou, antes de abrir o psql,
> `chcp 65001` no terminal.

### c) VS Code

Você já está no VS Code. Instale a extensão **PostgreSQL** (da Microsoft) ou **SQLTools**
+ *SQLTools PostgreSQL Driver*, crie uma conexão com `localhost`, porta `5432`, usuário
`postgres` e sua senha, e execute os arquivos `.sql` direto daqui.

## 0.4 Onde o banco é criado de verdade?

Quando você executa `CREATE DATABASE alura;`, o PostgreSQL cria uma **pasta** dentro do
seu *data directory*. Na instalação padrão do Windows:

```
C:\Program Files\PostgreSQL\17\data\        ← data directory (o "cluster")
 ├─ base\                                   ← um subdiretório por banco
 │   ├─ 1\        (template1)
 │   ├─ 4\        (template0)
 │   ├─ 5\        (postgres)
 │   └─ 16384\    (alura)   ← o número é o OID do banco
 ├─ global\                                 ← dados compartilhados (usuários, lista de bancos)
 ├─ pg_wal\                                 ← log de transações (recuperação após falhas)
 ├─ postgresql.conf                         ← configurações do servidor
 └─ pg_hba.conf                             ← quem pode se conectar e como
```

Cada tabela vira um ou mais arquivos dentro da pasta do banco. **Nunca edite, copie ou
apague esses arquivos manualmente** — use SQL (e `pg_dump` para backup).

Você pode confirmar tudo isso pelo próprio SQL:

```sql
-- Onde está o data directory?
SHOW data_directory;

-- Qual pasta (OID) corresponde a cada banco?
SELECT oid, datname FROM pg_database;

-- Em qual arquivo está a tabela aluno? (rode conectado ao banco alura)
SELECT pg_relation_filepath('aluno');

-- Quanto espaço o banco ocupa?
SELECT pg_size_pretty(pg_database_size('alura'));
```

> Se você usou Docker, o data directory fica dentro do container em
> `/var/lib/postgresql/data`, mapeado para o volume `pg-curso-dados`.

## 0.5 Primeiro teste

Conectado no banco `postgres`, rode:

```sql
SELECT version();
SELECT 1 + 1 AS resultado;
SELECT now();
```

Se você viu a versão, o número 2 e a data/hora atual, o ambiente está pronto.

## Exercícios

1. Descubra qual é o seu *data directory* e abra essa pasta no Explorer (só para olhar).
2. Liste os bancos existentes usando o pgAdmin **e** usando `\l` no psql.
3. Rode `SELECT current_user, current_database();`. O que cada coluna mostra?

<details><summary>Gabarito</summary>

1. `SHOW data_directory;` — normalmente `C:\Program Files\PostgreSQL\17\data`.
2. No pgAdmin: *Servers → PostgreSQL → Databases*. No psql: `\l`. Devem aparecer
   `postgres`, `template0` e `template1`.
3. `current_user` é o usuário conectado (`postgres`) e `current_database()` é o banco
   em que o Query Tool / psql está conectado.

</details>

Próximo: [Módulo 1 — Bancos e tabelas](01-bancos-e-tabelas.md)
