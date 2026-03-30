# obracerta-api

API RESTful para gestão de obras de construção civil, desenvolvida em Elixir com o framework Phoenix como trabalho avaliativo da disciplina Serviços Web (PF_CC.44) do curso de Ciência da Computação do IFSul Campus Passo Fundo.

---

## Contexto e decisão tecnológica

Tenho experiência profissional com Node.js e Fastify. Desenvolver mais uma API REST nessa stack não representaria aprendizado novo, apenas repetição do que já faço no dia a dia. Por isso, optei por explorar uma tecnologia completamente fora da minha zona de conforto: Elixir com o framework Phoenix.

Nunca havia aberto um projeto em Elixir antes deste trabalho.

O desenvolvimento foi conduzido com auxílio de inteligência artificial (Claude, da Anthropic). O prompt principal utilizado para gerar a estrutura da aplicação foi o seguinte:

```
Você é um desenvolvedor Elixir sênior. Implemente uma API RESTful COMPLETA de Gestão
de Obras (construção civil) em Elixir + Phoenix, atendendo TODOS os requisitos abaixo.
Gere CADA arquivo com caminho completo e conteúdo completo, sem omitir nada.

STACK:
- Elixir + Phoenix 1.8
- SQLite (ecto_sqlite3)
- Autenticação JWT (Guardian)
- Documentação OpenAPI (PhoenixSwagger + poison ~> 6.0)
- Hash de senha (bcrypt_elixir)

DOMÍNIO: Sistema de Gestão de Obras

Recursos:
- User (auth): name, email, password_hash
- Obra: titulo, endereco, descricao, status (enum: planejamento/em_andamento/concluida/pausada),
  orcamento (float), data_inicio (date), data_fim (date)
- Etapa (belongs_to Obra): titulo, descricao, status (enum: pendente/em_andamento/concluida),
  ordem (integer), obra_id
- Material (belongs_to Obra): nome, descricao, quantidade (float), unidade,
  custo_unitario (float), obra_id
```

O trabalho de avaliação, nesse sentido, não é apenas o código resultante. É verificar se, mesmo sem experiência prévia na linguagem, o resultado produzido com auxílio de IA atende aos critérios arquiteturais, é compreensível, executável e documentado adequadamente. Avalio aqui também a minha capacidade de entender, depurar e explicar o que foi gerado.

---

## Descrição do domínio

O sistema permite o gerenciamento de projetos de construção civil. O domínio foi escolhido por ter potencial de relação com meu trabalho de conclusão de curso e por ser rico o suficiente para justificar múltiplos recursos com relacionamentos reais entre si.

Os recursos modelados são:

**Obra**: representa um empreendimento de construção. Possui título, endereço, descrição, status de andamento, orçamento previsto e datas de início e término.

**Etapa**: representa uma fase de execução de uma obra. Cada etapa pertence a exatamente uma obra e possui uma ordem numérica que define sua sequência dentro do projeto.

**Material**: representa um insumo utilizado em uma obra. Cada material pertence a exatamente uma obra e carrega informações de quantidade, unidade de medida e custo unitário.

**User**: representa um usuário do sistema. Existe exclusivamente para fins de autenticação. Não é exposto como recurso REST além do endpoint de cadastro.

---

## Decisões técnicas

### Por que Elixir e não Node.js

Node.js opera com um único processo e um event loop. Toda a concorrência é gerenciada de forma assíncrona dentro dessa única thread. Isso funciona bem para I/O intensivo, mas tem limitações para processamento paralelo real.

Elixir roda sobre a BEAM, a máquina virtual do Erlang. O modelo de concorrência é baseado em processos leves e isolados: cada requisição recebe seu próprio processo, com memória própria, sem compartilhamento de estado. Um processo que falha não afeta os demais. A BEAM foi projetada para sistemas de telecomunicação que exigem alta disponibilidade, o que a torna uma escolha sólida para APIs sob carga.

A tabela abaixo resume as diferenças principais:

| Aspecto | Elixir/Phoenix | Node.js/Express |
|---|---|---|
| Modelo de concorrência | Processos leves isolados (BEAM) | Event loop single-threaded |
| Tolerância a falhas | Supervisors com restart automático (OTP) | Depende de ferramentas externas (PM2) |
| Estado compartilhado | Inexistente por design (imutabilidade) | Possível, requer cuidado explícito |
| Latência sob carga | Consistente e previsível | Pode degradar com backpressure |

### OTP e o princípio "let it crash"

OTP (Open Telecom Platform) é o conjunto de bibliotecas e padrões de design que acompanha o Erlang e é herdado pelo Elixir. O componente central é o Supervisor: um processo que monitora outros processos e os reinicia automaticamente quando falham, seguindo uma estratégia configurável.

Isso inverte a lógica defensiva comum em outras linguagens. Em vez de tentar capturar e tratar todo erro possível, o código Elixir deixa o processo falhar e confia que o supervisor vai reiniciá-lo em estado limpo. O resultado é um sistema mais simples e mais resiliente.

No projeto, a árvore de supervisão está em `lib/minha_api/application.ex` e é gerada automaticamente pelo Phoenix.

### Ecto como implementação do padrão DAO

O enunciado pede separação em camadas com uma camada de acesso a dados (DAO/Repository). O Ecto implementa esse padrão através de três componentes distintos:

**Schema**: define a estrutura de uma entidade e seu mapeamento para uma tabela do banco. É equivalente ao Model em outros frameworks.

**Changeset**: encapsula a lógica de validação e transformação de dados antes da persistência. Não existe equivalente direto em ORMs tradicionais como Sequelize ou ActiveRecord, onde validação e persistência costumam estar misturadas no mesmo objeto.

**Repo**: é o único ponto de contato com o banco de dados. Nenhum outro módulo executa queries diretamente.

A comparação com o padrão DAO clássico:

```
DAO clássico (Java)        Ecto (Elixir)
UserDAO.find(id)     -->   Repo.get(User, id)
UserDAO.save(user)   -->   Repo.insert(changeset)
UserDAO.update(user) -->   Repo.update(changeset)
UserDAO.delete(user) -->   Repo.delete(user)
```

### Arquitetura em camadas

O Phoenix segue naturalmente a separação exigida pelo enunciado:

```
Requisição HTTP
      |
      v
Router              -- mapeia URLs para controllers, aplica pipelines
      |
      v
Controller          -- extrai parâmetros, delega ao Context, renderiza resposta
      |
      v
Context (Service)   -- lógica de negócio, orquestra Schema e Repo
      |
      v
Repo (DAO)          -- executa queries no banco via Ecto
```

A divisão entre `lib/minha_api/` e `lib/minha_api_web/` é estrutural no Phoenix e reforça a separação de responsabilidades: tudo em `minha_api/` não tem conhecimento de HTTP e poderia ser reutilizado por qualquer outra interface (CLI, WebSocket, jobs agendados). Tudo em `minha_api_web/` lida exclusivamente com a camada HTTP.

### Autenticação JWT com Guardian

O Guardian é a biblioteca padrão do ecossistema Elixir para JWT. O fluxo implementado:

1. `POST /api/login` recebe email e senha
2. O Context `Auth` verifica a senha contra o hash armazenado usando `Bcrypt.verify_pass/2`
3. Se válido, `Guardian.encode_and_sign/1` gera um token JWT assinado com a chave configurada
4. O token é retornado ao cliente
5. Nas rotas protegidas, o pipeline do Guardian extrai o token do header `Authorization: Bearer ...`, valida a assinatura e carrega o usuário na conexão

O pipeline de autenticação é implementado como um Plug, que é o equivalente ao middleware do Express. Ele é aplicado seletivamente via `pipe_through` no router, separando rotas públicas de rotas protegidas.

A proteção contra timing attacks está implementada: quando o email não existe, `Bcrypt.no_user_verify/0` é chamado para garantir que o tempo de resposta seja equivalente ao de uma senha incorreta, impedindo enumeração de usuários por medição de tempo de resposta.

### Tratamento centralizado de erros

O Phoenix tem um padrão chamado `action_fallback` que funciona como um controller de fallback. Quando um controller retorna `{:error, reason}` em vez de renderizar uma resposta, o FallbackController intercepta e traduz o erro para o status HTTP adequado:

```
{:error, :not_found}      -->  404 Not Found
{:error, %Changeset{}}    -->  422 Unprocessable Entity
{:error, :unauthorized}   -->  401 Unauthorized
```

Isso centraliza o tratamento de erros em um único lugar, equivalente ao middleware de erro do Express com assinatura `(err, req, res, next)`.

### Banco de dados

Foi utilizado SQLite via `ecto_sqlite3`. A decisão foi pragmática: SQLite não exige servidor externo, o banco inteiro fica em um arquivo local (`priv/repo/dev.db`), simplificando a configuração para desenvolvimento e avaliação. A troca para PostgreSQL em produção exigiria apenas alterar o adapter no arquivo de configuração, sem mudanças no código da aplicação.

---

## Pré-requisitos

| Ferramenta | Versão |
|---|---|
| Elixir | ~> 1.16 |
| Erlang/OTP | ~> 26 |
| SQLite3 | 3.x |

Instalação via asdf:

```bash
asdf plugin add erlang
asdf plugin add elixir
asdf install erlang 26.2.5
asdf install elixir 1.16.3-otp-26
asdf global erlang 26.2.5
asdf global elixir 1.16.3-otp-26
```

---

## Instalação e execução

```bash
# Clonar o repositório
git clone https://github.com/SEU_USUARIO/obracerta-api.git
cd obracerta-api

# Instalar dependências
mix deps.get

# Criar o banco de dados SQLite
mix ecto.create

# Executar as migrations
mix ecto.migrate

# Popular com dados iniciais
mix run priv/repo/seeds.exs

# Gerar a documentação Swagger
mix phx.swagger.generate

# Iniciar o servidor
mix phx.server
```

O servidor responde em `http://localhost:4000`.
A documentação interativa está em `http://localhost:4000/api/api-docs`.

Para rodar os testes automatizados:

```bash
mix test
```

---

## Tabela de rotas

### Rotas públicas

| Método | Rota | Descrição | Status de sucesso | Status de erro |
|---|---|---|---|---|
| POST | /api/login | Autenticar e obter token JWT | 200 | 401 |
| POST | /api/users | Criar novo usuário | 201 | 422 |
| GET | /api/obras | Listar todas as obras | 200 | -- |
| GET | /api/obras/:id | Detalhar uma obra | 200 | 404 |
| GET | /api/etapas | Listar todas as etapas | 200 | -- |
| GET | /api/etapas/:id | Detalhar uma etapa | 200 | 404 |
| GET | /api/materiais | Listar todos os materiais | 200 | -- |
| GET | /api/materiais/:id | Detalhar um material | 200 | 404 |
| GET | /api/swagger | Documentação OpenAPI interativa | 200 | -- |

### Rotas protegidas (exigem header `Authorization: Bearer <token>`)

| Método | Rota | Descrição | Status de sucesso | Status de erro |
|---|---|---|---|---|
| POST | /api/obras | Criar obra | 201 | 401, 422 |
| PUT | /api/obras/:id | Atualizar obra | 200 | 401, 404, 422 |
| DELETE | /api/obras/:id | Remover obra | 204 | 401, 404 |
| POST | /api/etapas | Criar etapa | 201 | 401, 422 |
| PUT | /api/etapas/:id | Atualizar etapa | 200 | 401, 404, 422 |
| DELETE | /api/etapas/:id | Remover etapa | 204 | 401, 404 |
| POST | /api/materiais | Criar material | 201 | 401, 422 |
| PUT | /api/materiais/:id | Atualizar material | 200 | 401, 404, 422 |
| DELETE | /api/materiais/:id | Remover material | 204 | 401, 404 |

---

## Exemplos de uso

### Autenticar e obter token

```bash
curl -X POST http://localhost:4000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@obras.com", "password": "admin123"}'
```

Resposta:

```json
{
  "data": {
    "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "Admin",
      "email": "admin@obras.com"
    }
  }
}
```

### Usar o token em uma rota protegida

```bash
curl -X POST http://localhost:4000/api/obras \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
    "obra": {
      "titulo": "Residencial Parque das Acácias",
      "endereco": "Av. Brasil, 1500 - Passo Fundo/RS",
      "descricao": "Conjunto residencial de 4 blocos",
      "status": "planejamento",
      "orcamento": 8500000.00,
      "data_inicio": "2026-06-01",
      "data_fim": "2028-12-31"
    }
  }'
```

### Criar uma etapa vinculada a uma obra

```bash
curl -X POST http://localhost:4000/api/etapas \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
    "etapa": {
      "titulo": "Fundação",
      "descricao": "Escavação, sondagem e concretagem das sapatas",
      "status": "pendente",
      "ordem": 1,
      "obra_id": 1
    }
  }'
```

### Tentar acessar rota protegida sem token

```bash
curl -X POST http://localhost:4000/api/obras \
  -H "Content-Type: application/json" \
  -d '{"obra": {"titulo": "Teste"}}'
```

Resposta:

```json
{
  "error": "unauthenticated"
}
```

---

## Dados de exemplo (seeds)

O arquivo `priv/repo/seeds.exs` popula o banco com:

- 1 usuário administrador: `admin@obras.com` / `admin123`
- 3 obras com status distintos: `planejamento`, `em_andamento` e `concluida`
- 9 etapas distribuídas, 3 por obra, com ordens sequenciais
- 6 materiais distribuídos, 2 por obra

---

## Estrutura do projeto

```
lib/
  minha_api/
    auth.ex                    Context de autenticação (CRUD User + authenticate/2)
    auth/
      user.ex                  Schema User com hash de senha via bcrypt
      guardian.ex              Configuração JWT (encode/decode de tokens)
      pipeline.ex              Pipeline de autenticação (Plug)
      error_handler.ex         Retorna 401 para requisições não autenticadas
    construcao.ex              Context de construção (CRUD Obra, Etapa, Material)
    construcao/
      obra.ex                  Schema Obra (has_many etapas, has_many materiais)
      etapa.ex                 Schema Etapa (belongs_to obra)
      material.ex              Schema Material (belongs_to obra)
    repo.ex                    Ponto único de acesso ao banco (Ecto.Repo)
    application.ex             Árvore de supervisão OTP
  minha_api_web/
    router.ex                  Rotas, pipelines e configuração Swagger
    controllers/
      auth_controller.ex       POST /api/login
      user_controller.ex       POST /api/users
      obra_controller.ex       CRUD de obras com anotações OpenAPI
      etapa_controller.ex      CRUD de etapas com anotações OpenAPI
      material_controller.ex   CRUD de materiais com anotações OpenAPI
      fallback_controller.ex   Tratamento centralizado de erros (404, 422, 401)
      obra_json.ex             Serialização JSON de obras
      etapa_json.ex            Serialização JSON de etapas
      material_json.ex         Serialização JSON de materiais
priv/
  repo/
    migrations/                Histórico versionado do schema do banco
    seeds.exs                  Dados iniciais de demonstração
test/
  minha_api/
    auth_test.exs              Testes do Context de autenticação
    construcao_test.exs        Testes do Context de construção
  minha_api_web/controllers/
    obra_controller_test.exs   Testes HTTP dos endpoints de obras
    etapa_controller_test.exs
    material_controller_test.exs
```

---

## Testes automatizados

O projeto inclui 65 testes automatizados usando ExUnit, o framework de testes nativo do Elixir. Os testes cobrem:

- CRUD completo de todos os recursos via Context (sem HTTP)
- Validações de changeset: campos obrigatórios, formato de email, tamanho mínimo de senha, valores de enum, restrições numéricas
- Autenticação: hash de senha, credenciais válidas, senha incorreta, email inexistente
- Endpoints HTTP: respostas de sucesso, 401 para rotas protegidas sem token, 404 para recursos inexistentes, 422 para dados inválidos

O isolamento entre testes é garantido pelo Ecto Sandbox: cada teste roda dentro de uma transação que é revertida ao final, sem necessidade de limpeza manual do banco.

---

## Stack tecnológica

| Componente | Tecnologia |
|---|---|
| Linguagem | Elixir 1.16 |
| Framework HTTP | Phoenix 1.8 |
| Servidor HTTP | Bandit |
| Banco de dados | SQLite via ecto_sqlite3 |
| ORM | Ecto |
| Autenticação JWT | Guardian |
| Hash de senha | bcrypt_elixir |
| Documentação OpenAPI | PhoenixSwagger |
| Testes | ExUnit |

---

## Licença

MIT
