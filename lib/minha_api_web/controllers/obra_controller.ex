defmodule MinhaApiWeb.ObraController do
  use MinhaApiWeb, :controller
  use PhoenixSwagger

  alias MinhaApi.Construcao
  alias MinhaApi.Construcao.Obra

  action_fallback MinhaApiWeb.FallbackController

  swagger_path :index do
    get("/api/obras")
    summary("Lista todas as obras")
    description("Retorna a lista de todas as obras cadastradas")
    produces("application/json")
    response(200, "Sucesso")
  end

  def index(conn, _params) do
    obras = Construcao.list_obras()
    render(conn, :index, obras: obras)
  end

  swagger_path :show do
    get("/api/obras/{id}")
    summary("Exibe uma obra")
    description("Retorna os detalhes de uma obra específica")
    produces("application/json")
    parameter(:id, :path, :integer, "ID da obra", required: true)
    response(200, "Sucesso")
    response(404, "Obra não encontrada")
  end

  def show(conn, %{"id" => id}) do
    obra = Construcao.get_obra!(id)
    render(conn, :show, obra: obra)
  end

  swagger_path :create do
    post("/api/obras")
    summary("Cria uma nova obra")
    description("Cria uma nova obra (requer autenticação JWT)")
    produces("application/json")
    consumes("application/json")
    security([%{Bearer: []}])

    parameter(:obra, :body, Schema.ref(:ObraInput), "Dados da obra", required: true)

    response(201, "Obra criada com sucesso")
    response(422, "Dados inválidos")
  end

  def create(conn, %{"obra" => obra_params}) do
    with {:ok, %Obra{} = obra} <- Construcao.create_obra(obra_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/obras/#{obra}")
      |> render(:show, obra: obra)
    end
  end

  swagger_path :update do
    put("/api/obras/{id}")
    summary("Atualiza uma obra")
    description("Atualiza os dados de uma obra existente (requer autenticação JWT)")
    produces("application/json")
    consumes("application/json")
    security([%{Bearer: []}])

    parameter(:id, :path, :integer, "ID da obra", required: true)
    parameter(:obra, :body, Schema.ref(:ObraInput), "Dados da obra", required: true)

    response(200, "Obra atualizada com sucesso")
    response(404, "Obra não encontrada")
    response(422, "Dados inválidos")
  end

  def update(conn, %{"id" => id, "obra" => obra_params}) do
    obra = Construcao.get_obra!(id)

    with {:ok, %Obra{} = obra} <- Construcao.update_obra(obra, obra_params) do
      render(conn, :show, obra: obra)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/obras/{id}")
    summary("Exclui uma obra")
    description("Exclui uma obra existente (requer autenticação JWT)")
    security([%{Bearer: []}])
    parameter(:id, :path, :integer, "ID da obra", required: true)
    response(204, "Obra excluída com sucesso")
    response(404, "Obra não encontrada")
  end

  def delete(conn, %{"id" => id}) do
    obra = Construcao.get_obra!(id)

    with {:ok, %Obra{}} <- Construcao.delete_obra(obra) do
      send_resp(conn, :no_content, "")
    end
  end

  def swagger_definitions do
    %{
      ObraInput:
        swagger_schema do
          title("ObraInput")
          description("Dados para criação/atualização de uma obra")

          properties do
            titulo(:string, "Título da obra", required: true)
            endereco(:string, "Endereço da obra", required: true)
            descricao(:string, "Descrição da obra")
            status(:string, "Status da obra (planejamento, em_andamento, concluida, pausada)", required: true)
            orcamento(:number, "Orçamento da obra", required: true)
            data_inicio(:string, "Data de início (YYYY-MM-DD)", required: true, format: "date")
            data_fim(:string, "Data de fim (YYYY-MM-DD)", format: "date")
          end
        end
    }
  end
end
