# API de Gestão de Obras 🏗️

API RESTful para gerenciamento de obras de construção civil, desenvolvida em **Elixir + Phoenix**.

## Descrição do Domínio

O **Sistema de Gestão de Obras** permite o gerenciamento completo de projetos de construção civil, incluindo:

- **Obras**: cadastro e acompanhamento de empreendimentos com orçamento, datas e status
- **Etapas**: decomposição de cada obra em fases ordenadas (fundação, estrutura, etc.)
- **Materiais**: controle de insumos utilizados em cada obra com quantidades e custos unitários
- **Autenticação JWT**: proteção de rotas de escrita via Bearer token

---

## Pré-requisitos

| Ferramenta | Versão Mínima |
|------------|--------------|
| Elixir | ~> 1.15 |
| Erlang/OTP | ~> 26 |
| SQLite3 | 3.x |

### Instalação via asdf

```bash
asdf plugin add erlang
asdf plugin add elixir
asdf install erlang 27.0
asdf install elixir 1.17.2-otp-27
asdf global erlang 27.0
asdf global elixir 1.17.2-otp-27
```

---

## Instalação e Execução

```bash
# Instalar dependências
mix deps.get

# Criar banco de dados SQLite
mix ecto.create

# Executar migrations
mix ecto.migrate

# Popular com dados iniciais
mix run priv/repo/seeds.exs

# Gerar documentação Swagger (OpenAPI)
mix phx.swagger.generate

# Iniciar o servidor
mix phx.server
```

O servidor estará disponível em `http://localhost:4000`.
A documentação Swagger estará em `http://localhost:4000/api/swagger`.

---

## Tabela de Rotas

### Rotas Públicas (sem autenticação)

| Método | Rota | Descrição | Status Codes |
|--------|------|-----------|-------------|
| `POST` | `/api/login` | Autenticar e obter JWT | 200, 401 |
| `POST` | `/api/users` | Criar novo usuário | 201, 422 |
| `GET` | `/api/obras` | Listar todas as obras | 200 |
| `GET` | `/api/obras/:id` | Detalhes de uma obra | 200, 404 |
| `GET` | `/api/etapas` | Listar todas as etapas | 200 |
| `GET` | `/api/etapas/:id` | Detalhes de uma etapa | 200, 404 |
| `GET` | `/api/materiais` | Listar todos os materiais | 200 |
| `GET` | `/api/materiais/:id` | Detalhes de um material | 200, 404 |

### Rotas Protegidas (requerem JWT no header `Authorization: Bearer <token>`)

| Método | Rota | Descrição | Status Codes |
|--------|------|-----------|-------------|
| `POST` | `/api/obras` | Criar obra | 201, 422 |
| `PUT` | `/api/obras/:id` | Atualizar obra | 200, 404, 422 |
| `DELETE` | `/api/obras/:id` | Excluir obra | 204, 404 |
| `POST` | `/api/etapas` | Criar etapa | 201, 422 |
| `PUT` | `/api/etapas/:id` | Atualizar etapa | 200, 404, 422 |
| `DELETE` | `/api/etapas/:id` | Excluir etapa | 204, 404 |
| `POST` | `/api/materiais` | Criar material | 201, 422 |
| `PUT` | `/api/materiais/:id` | Atualizar material | 200, 404, 422 |
| `DELETE` | `/api/materiais/:id` | Excluir material | 204, 404 |

### Swagger UI

| Rota | Descrição |
|------|-----------|
| `/api/swagger` | Documentação interativa OpenAPI/Swagger |

---

## Exemplo de Uso

### 1. Criar um usuário

```bash
curl -X POST http://localhost:4000/api/users \
  -H "Content-Type: application/json" \
  -d '{"user": {"name": "João", "email": "joao@email.com", "password": "senha123"}}'
```

### 2. Fazer login e obter o token JWT

```bash
curl -X POST http://localhost:4000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@obras.com", "password": "admin123"}'
```

**Resposta:**
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 3. Usar o token para criar uma obra (rota protegida)

```bash
curl -X POST http://localhost:4000/api/obras \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
    "obra": {
      "titulo": "Nova Obra",
      "endereco": "Rua Exemplo, 100",
      "descricao": "Descrição da obra",
      "status": "planejamento",
      "orcamento": 1000000.00,
      "data_inicio": "2025-06-01",
      "data_fim": "2026-12-31"
    }
  }'
```

### 4. Listar obras (rota pública)

```bash
curl http://localhost:4000/api/obras
```

### 5. Criar uma etapa vinculada a uma obra

```bash
curl -X POST http://localhost:4000/api/etapas \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
    "etapa": {
      "titulo": "Fundação",
      "descricao": "Escavação e concretagem",
      "status": "pendente",
      "ordem": 1,
      "obra_id": 1
    }
  }'
```

---

## Contextualização Tecnológica

### Por que Elixir/Phoenix vs Node/Express?

| Aspecto | Elixir/Phoenix | Node/Express |
|---------|---------------|-------------|
| **Concorrência** | Modelo de atores (processos leves) via BEAM VM — milhões de processos simultâneos | Single-threaded com event loop; Worker Threads para CPU-bound |
| **Tolerância a falhas** | Supervisors com estratégias de restart (OTP) — "let it crash" | Necessita de bibliotecas externas (PM2, cluster) |
| **Performance** | Latência consistente e previsível sob alta carga | Pode sofrer com "callback hell" e GC pauses |
| **Hot Code Upgrade** | Suporte nativo via OTP releases | Requer restart completo da aplicação |
| **Imutabilidade** | Dados imutáveis por padrão — sem bugs de estado compartilhado | Mutabilidade por padrão — propenso a race conditions |

### O que é OTP?

**OTP (Open Telecom Platform)** é um conjunto de bibliotecas e padrões de design incluídos no Erlang/Elixir que fornecem:

- **GenServer**: processos genéricos para encapsular estado e lógica
- **Supervisor**: árvores de supervisão que reiniciam processos falhados automaticamente
- **Application**: empacotamento de código como aplicações autocontidas
- **ETS / DETS**: armazenamento em memória de alta performance
- **Registry / DynamicSupervisor**: registro e supervisão dinâmica de processos

O OTP permite construir sistemas distribuídos, tolerantes a falhas e altamente disponíveis — qualidades essenciais para APIs em produção.

### Ecto como padrão DAO (Data Access Object)

O **Ecto** implementa o padrão **Repository**, que é uma evolução do DAO clássico:

```
DAO Clássico (Java)          Ecto (Elixir)
─────────────────            ────────────────
UserDAO.find(id)     →       Repo.get(User, id)
UserDAO.save(user)   →       Repo.insert(changeset)
UserDAO.update(user) →       Repo.update(changeset)
UserDAO.delete(user) →       Repo.delete(user)
```

Os **Changesets** adicionam uma camada de validação e transformação que os DAOs tradicionais não possuem, permitindo validar dados antes mesmo de tocar o banco de dados.

### Arquitetura Router → Controller → Context → Repo

O Phoenix segue uma arquitetura em camadas similar ao padrão MVC adaptado para APIs:

```
Request HTTP
    │
    ▼
┌─────────┐
│  Router  │  Define rotas e pipelines (middlewares)
└────┬────┘
     ▼
┌────────────┐
│ Controller │  Recebe params, delega ao Context, renderiza resposta
└─────┬──────┘
      ▼
┌──────────┐
│ Context  │  Lógica de negócio (Service Layer)
└─────┬────┘
      ▼
┌──────┐
│ Repo │  Acesso ao banco de dados (DAO/Repository)
└──────┘
```

- **Router**: análogo ao Express Router — mapeia URLs para controllers
- **Controller**: camada fina que traduz HTTP ↔ domínio
- **Context** (`Auth`, `Construcao`): encapsula toda a lógica de negócio — equivalente a uma Service Layer
- **Repo**: abstração única de acesso ao banco — padrão Repository/DAO

Essa separação garante testabilidade, manutenibilidade e clareza na organização do código.

---

## Estrutura do Projeto

```
lib/
├── minha_api/
│   ├── auth/
│   │   ├── error_handler.ex    # Guardian error handler (401)
│   │   ├── guardian.ex          # JWT token encode/decode
│   │   ├── pipeline.ex          # Auth pipeline (VerifyHeader + EnsureAuthenticated)
│   │   └── user.ex              # Schema User com bcrypt
│   ├── construcao/
│   │   ├── etapa.ex             # Schema Etapa (belongs_to Obra)
│   │   ├── material.ex          # Schema Material (belongs_to Obra)
│   │   └── obra.ex              # Schema Obra (has_many Etapas/Materiais)
│   ├── auth.ex                  # Context Auth (CRUD + authenticate)
│   └── construcao.ex            # Context Construcao (CRUD Obra/Etapa/Material)
├── minha_api_web/
│   ├── controllers/
│   │   ├── auth_controller.ex   # Login (JWT)
│   │   ├── etapa_controller.ex  # CRUD + Swagger
│   │   ├── material_controller.ex # CRUD + Swagger
│   │   ├── obra_controller.ex   # CRUD + Swagger
│   │   ├── user_controller.ex   # Create user
│   │   ├── fallback_controller.ex # Error handling (401/404/422)
│   │   ├── *_json.ex            # JSON views
│   │   └── error_json.ex        # Error rendering
│   └── router.ex                # Routes + Swagger config
```

---

## Licença

MIT
