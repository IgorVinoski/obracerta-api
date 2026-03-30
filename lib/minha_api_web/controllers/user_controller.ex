defmodule MinhaApiWeb.UserController do
  use MinhaApiWeb, :controller

  alias MinhaApi.Auth
  alias MinhaApi.Auth.User

  action_fallback MinhaApiWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Auth.create_user(user_params) do
      conn
      |> put_status(:created)
      |> render(:show, user: user)
    end
  end
end
