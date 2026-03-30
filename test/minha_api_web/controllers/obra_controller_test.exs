defmodule MinhaApiWeb.ObraControllerTest do
  use MinhaApiWeb.ConnCase

  import MinhaApi.ConstrucaoFixtures
  import MinhaApi.AuthFixtures
  alias MinhaApi.Construcao.Obra

  @create_attrs %{
    status: "planejamento",
    titulo: "some titulo",
    endereco: "some endereco",
    descricao: "some descricao",
    orcamento: 120.5,
    data_inicio: ~D[2026-03-24],
    data_fim: ~D[2026-03-24]
  }
  @update_attrs %{
    status: "em_andamento",
    titulo: "some updated titulo",
    endereco: "some updated endereco",
    descricao: "some updated descricao",
    orcamento: 456.7,
    data_inicio: ~D[2026-03-25],
    data_fim: ~D[2026-03-25]
  }
  @invalid_attrs %{status: nil, titulo: nil, endereco: nil, descricao: nil, orcamento: nil, data_inicio: nil, data_fim: nil}

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
    test "lists all obras", %{conn: conn} do
      conn = get(conn, ~p"/api/obras")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create obra" do
    test "renders obra when data is valid", %{authed_conn: conn} do
      conn = post(conn, ~p"/api/obras", obra: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/obras/#{id}")

      assert %{
               "id" => ^id,
               "data_fim" => "2026-03-24",
               "data_inicio" => "2026-03-24",
               "descricao" => "some descricao",
               "endereco" => "some endereco",
               "orcamento" => 120.5,
               "status" => "planejamento",
               "titulo" => "some titulo"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{authed_conn: conn} do
      conn = post(conn, ~p"/api/obras", obra: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 401 without auth token", %{conn: conn} do
      conn = post(conn, ~p"/api/obras", obra: @create_attrs)
      assert json_response(conn, 401)
    end
  end

  describe "update obra" do
    setup [:create_obra]

    test "renders obra when data is valid", %{authed_conn: conn, obra: %Obra{id: id} = obra} do
      conn = put(conn, ~p"/api/obras/#{obra}", obra: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/obras/#{id}")

      assert %{
               "id" => ^id,
               "data_fim" => "2026-03-25",
               "data_inicio" => "2026-03-25",
               "descricao" => "some updated descricao",
               "endereco" => "some updated endereco",
               "orcamento" => 456.7,
               "status" => "em_andamento",
               "titulo" => "some updated titulo"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{authed_conn: conn, obra: obra} do
      conn = put(conn, ~p"/api/obras/#{obra}", obra: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete obra" do
    setup [:create_obra]

    test "deletes chosen obra", %{authed_conn: conn, obra: obra} do
      conn = delete(conn, ~p"/api/obras/#{obra}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/obras/#{obra}")
      end
    end
  end

  defp create_obra(_) do
    obra = obra_fixture()

    %{obra: obra}
  end
end
