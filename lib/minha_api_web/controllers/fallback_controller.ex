defmodule MinhaApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use MinhaApiWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: MinhaApiWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause handles resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: MinhaApiWeb.ErrorJSON)
    |> render(:"404")
  end

  # This clause handles unauthorized errors.
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: MinhaApiWeb.ErrorJSON)
    |> render(:"401")
  end
end
