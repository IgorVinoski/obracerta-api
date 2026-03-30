# Seeds for the Gestão de Obras API
# Run with: mix run priv/repo/seeds.exs

alias MinhaApi.Repo
alias MinhaApi.Auth.User
alias MinhaApi.Construcao.Obra
alias MinhaApi.Construcao.Etapa
alias MinhaApi.Construcao.Material

# --- User ---
{:ok, _admin} =
  %User{}
  |> User.changeset(%{
    name: "Admin",
    email: "admin@obras.com",
    password: "admin123"
  })
  |> Repo.insert()

IO.puts("✅ Usuário Admin criado (admin@obras.com / admin123)")

# --- Obras ---
{:ok, obra1} =
  %Obra{}
  |> Obra.changeset(%{
    titulo: "Residencial Parque das Flores",
    endereco: "Rua das Acácias, 150 - São Paulo/SP",
    descricao: "Condomínio residencial com 4 torres e 200 apartamentos",
    status: "em_andamento",
    orcamento: 15_000_000.00,
    data_inicio: ~D[2025-01-15],
    data_fim: ~D[2027-06-30]
  })
  |> Repo.insert()

{:ok, obra2} =
  %Obra{}
  |> Obra.changeset(%{
    titulo: "Edifício Comercial Centro Empresarial",
    endereco: "Av. Paulista, 1500 - São Paulo/SP",
    descricao: "Edifício comercial de 20 andares com lojas no térreo",
    status: "planejamento",
    orcamento: 45_000_000.00,
    data_inicio: ~D[2026-03-01],
    data_fim: ~D[2029-12-31]
  })
  |> Repo.insert()

{:ok, obra3} =
  %Obra{}
  |> Obra.changeset(%{
    titulo: "Reforma Escola Municipal Dom Pedro II",
    endereco: "Rua XV de Novembro, 80 - Curitiba/PR",
    descricao: "Reforma completa da escola incluindo quadra poliesportiva",
    status: "concluida",
    orcamento: 2_500_000.00,
    data_inicio: ~D[2024-06-01],
    data_fim: ~D[2025-02-28]
  })
  |> Repo.insert()

IO.puts("✅ 3 obras criadas")

# --- Etapas ---
obras_etapas = [
  {obra1, [
    %{titulo: "Fundação", descricao: "Escavação e concretagem das fundações", status: "concluida", ordem: 1},
    %{titulo: "Estrutura", descricao: "Montagem da estrutura de concreto armado", status: "em_andamento", ordem: 2},
    %{titulo: "Alvenaria", descricao: "Levantamento de paredes e vedações", status: "pendente", ordem: 3}
  ]},
  {obra2, [
    %{titulo: "Projeto Executivo", descricao: "Elaboração dos projetos detalhados", status: "em_andamento", ordem: 1},
    %{titulo: "Licenciamento", descricao: "Obtenção de licenças e alvarás", status: "pendente", ordem: 2},
    %{titulo: "Terraplanagem", descricao: "Preparação do terreno para construção", status: "pendente", ordem: 3}
  ]},
  {obra3, [
    %{titulo: "Demolição", descricao: "Demolição das estruturas existentes", status: "concluida", ordem: 1},
    %{titulo: "Reconstrução", descricao: "Reconstrução das áreas demolidas", status: "concluida", ordem: 2},
    %{titulo: "Acabamento", descricao: "Pintura, pisos e acabamentos finais", status: "concluida", ordem: 3}
  ]}
]

for {obra, etapas} <- obras_etapas, etapa_attrs <- etapas do
  %Etapa{}
  |> Etapa.changeset(Map.put(etapa_attrs, :obra_id, obra.id))
  |> Repo.insert!()
end

IO.puts("✅ 9 etapas criadas (3 por obra)")

# --- Materiais ---
obras_materiais = [
  {obra1, [
    %{nome: "Cimento Portland CP-II", descricao: "Cimento para uso geral em concretagem", quantidade: 5000.0, unidade: "kg", custo_unitario: 0.85},
    %{nome: "Aço CA-50", descricao: "Vergalhão de aço para armadura", quantidade: 12000.0, unidade: "kg", custo_unitario: 5.20}
  ]},
  {obra2, [
    %{nome: "Concreto Usinado FCK 30", descricao: "Concreto pronto para estruturas", quantidade: 800.0, unidade: "m³", custo_unitario: 450.00},
    %{nome: "Bloco Cerâmico 14x19x29", descricao: "Bloco para alvenaria estrutural", quantidade: 50000.0, unidade: "un", custo_unitario: 2.30}
  ]},
  {obra3, [
    %{nome: "Tinta Acrílica Premium", descricao: "Tinta para pintura interna e externa", quantidade: 200.0, unidade: "litro", custo_unitario: 89.90},
    %{nome: "Porcelanato 60x60", descricao: "Piso porcelanato para áreas comuns", quantidade: 1500.0, unidade: "m²", custo_unitario: 65.00}
  ]}
]

for {obra, materiais} <- obras_materiais, material_attrs <- materiais do
  %Material{}
  |> Material.changeset(Map.put(material_attrs, :obra_id, obra.id))
  |> Repo.insert!()
end

IO.puts("✅ 6 materiais criados (2 por obra)")
IO.puts("\n🏗️  Seeds concluídos com sucesso!")
