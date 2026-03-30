defmodule MinhaApiWeb.MaterialControllerTest do
  use MinhaApiWeb.ConnCase

  import MinhaApi.ConstrucaoFixtures
  import MinhaApi.AuthFixtures
  alias MinhaApi.Construcao.Material

  @update_attrs %{
    nome: "some updated nome",
    descricao: "some updated descricao",
    quantidade: 456.7,
    unidade: "some updated unidade",
    custo_unitario: 456.7
  }
  @invalid_attrs %{nome: nil, descricao: nil, quantidade: nil, unidade: nil, custo_unitario: nil}

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
    test "lists all materiais", %{conn: conn} do
      conn = get(conn, ~p"/api/materiais")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create material" do
    test "renders material when data is valid", %{authed_conn: conn} do
      obra = obra_fixture()
      create_attrs = %{nome: "some nome", descricao: "some descricao", quantidade: 120.5, unidade: "some unidade", custo_unitario: 120.5, obra_id: obra.id}

      conn = post(conn, ~p"/api/materiais", material: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/materiais/#{id}")

      assert %{
               "id" => ^id,
               "custo_unitario" => 120.5,
               "descricao" => "some descricao",
               "nome" => "some nome",
               "quantidade" => 120.5,
               "unidade" => "some unidade"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{authed_conn: conn} do
      conn = post(conn, ~p"/api/materiais", material: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns 401 without auth token", %{conn: conn} do
      conn = post(conn, ~p"/api/materiais", material: %{})
      assert json_response(conn, 401)
    end
  end

  describe "update material" do
    setup [:create_material]

    test "renders material when data is valid", %{authed_conn: conn, material: %Material{id: id} = material} do
      conn = put(conn, ~p"/api/materiais/#{material}", material: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/materiais/#{id}")

      assert %{
               "id" => ^id,
               "custo_unitario" => 456.7,
               "descricao" => "some updated descricao",
               "nome" => "some updated nome",
               "quantidade" => 456.7,
               "unidade" => "some updated unidade"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{authed_conn: conn, material: material} do
      conn = put(conn, ~p"/api/materiais/#{material}", material: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete material" do
    setup [:create_material]

    test "deletes chosen material", %{authed_conn: conn, material: material} do
      conn = delete(conn, ~p"/api/materiais/#{material}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/materiais/#{material}")
      end
    end
  end

  defp create_material(_) do
    material = material_fixture()

    %{material: material}
  end
end
