defmodule MinhaApiWeb.EtapaControllerTest do
  use MinhaApiWeb.ConnCase

  import MinhaApi.ConstrucaoFixtures
  import MinhaApi.AuthFixtures
  alias MinhaApi.Construcao.Etapa

  @update_attrs %{
    status: "em_andamento",
    titulo: "some updated titulo",
    descricao: "some updated descricao",
    ordem: 43
  }
  @invalid_attrs %{status: nil, titulo: nil, descricao: nil, ordem: nil}

  setup %{conn: conn} do
    user = user_fixture()
    {:ok, token, _claims} = MinhaApi.Auth.Guardian.encode_and_sign(user)

    authed_conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "Bearer #{token}")

    {:ok, conn: put_req_header(conn, "accept", "application/json"), authed_conn: authed_conn}
  end

  describe "index" do
    test "lists all etapas", %{conn: conn} do
      conn = get(conn, ~p"/api/etapas")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create etapa" do
    test "renders etapa when data is valid", %{authed_conn: conn} do
      obra = obra_fixture()
      create_attrs = %{status: "pendente", titulo: "some titulo", descricao: "some descricao", ordem: 42, obra_id: obra.id}

      conn = post(conn, ~p"/api/etapas", etapa: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/etapas/#{id}")

      assert %{
               "id" => ^id,
               "descricao" => "some descricao",
               "ordem" => 42,
               "status" => "pendente",
               "titulo" => "some titulo"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{authed_conn: conn} do
      conn = post(conn, ~p"/api/etapas", etapa: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 401 without auth token", %{conn: conn} do
      conn = post(conn, ~p"/api/etapas", etapa: %{})
      assert json_response(conn, 401)
    end
  end

  describe "update etapa" do
    setup [:create_etapa]

    test "renders etapa when data is valid", %{authed_conn: conn, etapa: %Etapa{id: id} = etapa} do
      conn = put(conn, ~p"/api/etapas/#{etapa}", etapa: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/etapas/#{id}")

      assert %{
               "id" => ^id,
               "descricao" => "some updated descricao",
               "ordem" => 43,
               "status" => "em_andamento",
               "titulo" => "some updated titulo"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{authed_conn: conn, etapa: etapa} do
      conn = put(conn, ~p"/api/etapas/#{etapa}", etapa: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete etapa" do
    setup [:create_etapa]

    test "deletes chosen etapa", %{authed_conn: conn, etapa: etapa} do
      conn = delete(conn, ~p"/api/etapas/#{etapa}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/etapas/#{etapa}")
      end
    end
  end

  defp create_etapa(_) do
    etapa = etapa_fixture()

    %{etapa: etapa}
  end
end
