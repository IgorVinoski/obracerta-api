defmodule MinhaApiWeb.EtapaController do
  use MinhaApiWeb, :controller
  use PhoenixSwagger

  alias MinhaApi.Construcao
  alias MinhaApi.Construcao.Etapa

  action_fallback MinhaApiWeb.FallbackController

  swagger_path :index do
    get("/api/etapas")
    summary("Lista todas as etapas")
    description("Retorna a lista de todas as etapas cadastradas")
    produces("application/json")
    response(200, "Sucesso")
  end

  def index(conn, _params) do
    etapas = Construcao.list_etapas()
    render(conn, :index, etapas: etapas)
  end

  swagger_path :show do
    get("/api/etapas/{id}")
    summary("Exibe uma etapa")
    description("Retorna os detalhes de uma etapa específica")
    produces("application/json")
    parameter(:id, :path, :integer, "ID da etapa", required: true)
    response(200, "Sucesso")
    response(404, "Etapa não encontrada")
  end

  def show(conn, %{"id" => id}) do
    etapa = Construcao.get_etapa!(id)
    render(conn, :show, etapa: etapa)
  end

  swagger_path :create do
    post("/api/etapas")
    summary("Cria uma nova etapa")
    description("Cria uma nova etapa vinculada a uma obra (requer autenticação JWT)")
    produces("application/json")
    consumes("application/json")
    security([%{Bearer: []}])

    parameter(:etapa, :body, Schema.ref(:EtapaInput), "Dados da etapa", required: true)

    response(201, "Etapa criada com sucesso")
    response(422, "Dados inválidos")
  end

  def create(conn, %{"etapa" => etapa_params}) do
    with {:ok, %Etapa{} = etapa} <- Construcao.create_etapa(etapa_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/etapas/#{etapa}")
      |> render(:show, etapa: etapa)
    end
  end

  swagger_path :update do
    put("/api/etapas/{id}")
    summary("Atualiza uma etapa")
    description("Atualiza os dados de uma etapa existente (requer autenticação JWT)")
    produces("application/json")
    consumes("application/json")
    security([%{Bearer: []}])

    parameter(:id, :path, :integer, "ID da etapa", required: true)
    parameter(:etapa, :body, Schema.ref(:EtapaInput), "Dados da etapa", required: true)

    response(200, "Etapa atualizada com sucesso")
    response(404, "Etapa não encontrada")
    response(422, "Dados inválidos")
  end

  def update(conn, %{"id" => id, "etapa" => etapa_params}) do
    etapa = Construcao.get_etapa!(id)

    with {:ok, %Etapa{} = etapa} <- Construcao.update_etapa(etapa, etapa_params) do
      render(conn, :show, etapa: etapa)
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/api/etapas/{id}")
    summary("Exclui uma etapa")
    description("Exclui uma etapa existente (requer autenticação JWT)")
    security([%{Bearer: []}])
    parameter(:id, :path, :integer, "ID da etapa", required: true)
    response(204, "Etapa excluída com sucesso")
    response(404, "Etapa não encontrada")
  end

  def delete(conn, %{"id" => id}) do
    etapa = Construcao.get_etapa!(id)

    with {:ok, %Etapa{}} <- Construcao.delete_etapa(etapa) do
      send_resp(conn, :no_content, "")
    end
  end

  def swagger_definitions do
    %{
      EtapaInput:
        swagger_schema do
          title("EtapaInput")
          description("Dados para criação/atualização de uma etapa")

          properties do
            titulo(:string, "Título da etapa", required: true)
            descricao(:string, "Descrição da etapa")
            status(:string, "Status da etapa (pendente, em_andamento, concluida)", required: true)
            ordem(:integer, "Ordem da etapa na obra", required: true)
            obra_id(:integer, "ID da obra associada", required: true)
          end
        end
    }
  end
end
