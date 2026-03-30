defmodule MinhaApiWeb.UserControllerTest do
  use MinhaApiWeb.ConnCase

  @create_attrs %{
    name: "some name",
    email: "user@example.com",
    password: "password123"
  }
  @invalid_attrs %{name: nil, email: nil, password: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @create_attrs)
      assert %{"id" => _id} = json_response(conn, 201)["data"]

      response_data = json_response(conn, 201)["data"]
      assert response_data["name"] == "some name"
      assert response_data["email"] == "user@example.com"
      refute Map.has_key?(response_data, "password_hash")
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/users", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
