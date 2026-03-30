defmodule MinhaApiWeb.AuthController do
  use MinhaApiWeb, :controller

  alias MinhaApi.Auth
  alias MinhaApi.Auth.Guardian

  action_fallback MinhaApiWeb.FallbackController

  def login(conn, %{"email" => email, "password" => password}) do
    with {:ok, user} <- Auth.authenticate(email, password),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:ok)
      |> json(%{data: %{token: token}})
    end
  end
end
