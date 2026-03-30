defmodule MinhaApi.AuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MinhaApi.Auth` context.
  """

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "user#{System.unique_integer([:positive])}@test.com"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: unique_user_email(),
        name: "some name",
        password: "password123"
      })
      |> MinhaApi.Auth.create_user()

    user
  end
end
