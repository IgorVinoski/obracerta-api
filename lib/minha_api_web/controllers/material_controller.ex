defmodule MinhaApiWeb.MaterialController do
  use MinhaApiWeb, :controller
  use PhoenixSwagger

  alias MinhaApi.Construcao
  alias MinhaApi.Construcao.Material

  action_fallback MinhaApiWeb.FallbackController

  swagger_path :index do
    get("/api/materiais")
    summary("Lista todos os materiais")
    description("Retorna a lista de todos os materiais cadastrados")
    produces("application/json")
    response(200, "Sucesso")
  end

  def index(conn, _params) do
    materiais = Construcao.list_materiais()
    render(conn, :index, materiais: materiais)
  end

  swagger_path :show do
    get("/api/materiais/{id}")
    summary("Exibe um material")
    description("Retorna os detalhes de um material específico")
    produces("application/json")
    parameter(:id, :path, :integer, "ID do material", required: true)
    response(200, "Sucesso")
    response(404, "Material não encontrado")
  end

  def show(conn, %{"id" => id}) do
    material = Construcao.get_material!(id)
    render(conn, :show, material: material)
  end

  swagger_path :create do
    post("/api/materiais")
    summary("Cria um novo material")
    description("Cria um novo material vinculado a uma obra (requer autenticação JWT)")
    produces("application/json")
    consumes("application/json")
    security([%{Bearer: []}])

    parameter(:material, :body, Schema.ref(:MaterialInput), "Dados do material", required: true)

    response(201, "Material criado com sucesso")
    response(422, "Dados inválidos")
  end

  def create(conn, %{"material" => material_params}) do
    with {:ok, %Material{} = material} <- Construcao.create_material(material_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/materiais/#{material}")
      |> render(:show, material: material)
    end
  end

  swagger_path :update do
    put("/api/materiais/{id}")
    summary("Atualiza um material")
    description("Atualiza os dados de um material existente (requer autenticação JWT)")
    produces("application/json")
    consumes("application/json")
    security([%{Bearer: []}])

    parameter(:id, :path, :integer, "ID do material", required: true)
    parameter(:material, :body, Schema.ref(:MaterialInput), "Dados do material", required: true)

    response(200, "Material atualizado com sucesso")
    response(404, "Material não encontrado")
    response(422, "Dados inválidos")
  end

  def update(conn, %{"id" => id, "material" => material_params}) do
    material = Construcao.get_material!(id)

    with {:ok, %Material{} = material} <- Construcao.update_material(material, material_params) do
      render(conn, :show, material: material)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/materiais/{id}")
    summary("Exclui um material")
    description("Exclui um material existente (requer autenticação JWT)")
    security([%{Bearer: []}])
    parameter(:id, :path, :integer, "ID do material", required: true)
    response(204, "Material excluído com sucesso")
    response(404, "Material não encontrado")
  end

  def delete(conn, %{"id" => id}) do
    material = Construcao.get_material!(id)

    with {:ok, %Material{}} <- Construcao.delete_material(material) do
      send_resp(conn, :no_content, "")
    end
  end

  def swagger_definitions do
    %{
      MaterialInput:
        swagger_schema do
          title("MaterialInput")
          description("Dados para criação/atualização de um material")

          properties do
            nome(:string, "Nome do material", required: true)
            descricao(:string, "Descrição do material")
            quantidade(:number, "Quantidade do material", required: true)
            unidade(:string, "Unidade de medida (kg, m, un, etc.)", required: true)
            custo_unitario(:number, "Custo unitário do material", required: true)
            obra_id(:integer, "ID da obra associada", required: true)
          end
        end
    }
  end
end
