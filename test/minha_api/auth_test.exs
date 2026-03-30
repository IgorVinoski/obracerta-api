defmodule MinhaApi.AuthTest do
  use MinhaApi.DataCase

  alias MinhaApi.Auth

  describe "users" do
    alias MinhaApi.Auth.User

    import MinhaApi.AuthFixtures

    @invalid_attrs %{name: nil, email: nil, password: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      [loaded_user] = Auth.list_users()
      assert loaded_user.id == user.id
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      loaded_user = Auth.get_user!(user.id)
      assert loaded_user.id == user.id
      assert loaded_user.email == user.email
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{name: "some name", email: "test@example.com", password: "password123"}

      assert {:ok, %User{} = user} = Auth.create_user(valid_attrs)
      assert user.name == "some name"
      assert user.email == "test@example.com"
      assert Bcrypt.verify_pass("password123", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "create_user/1 validates email format" do
      attrs = %{name: "name", email: "invalid", password: "password123"}
      assert {:error, %Ecto.Changeset{} = changeset} = Auth.create_user(attrs)
      assert %{email: _} = errors_on(changeset)
    end

    test "create_user/1 validates password min length" do
      attrs = %{name: "name", email: "valid@email.com", password: "short"}
      assert {:error, %Ecto.Changeset{} = changeset} = Auth.create_user(attrs)
      assert %{password: _} = errors_on(changeset)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{name: "some updated name", email: "updated@email.com", password: "newpassword123"}

      assert {:ok, %User{} = user} = Auth.update_user(user, update_attrs)
      assert user.name == "some updated name"
      assert user.email == "updated@email.com"
      assert Bcrypt.verify_pass("newpassword123", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      loaded_user = Auth.get_user!(user.id)
      assert loaded_user.id == user.id
      assert loaded_user.email == user.email
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end

    test "authenticate/2 with valid credentials returns user" do
      user = user_fixture(%{email: "auth@test.com", password: "password123"})
      assert {:ok, authenticated_user} = Auth.authenticate("auth@test.com", "password123")
      assert authenticated_user.id == user.id
    end

    test "authenticate/2 with wrong password returns error" do
      _user = user_fixture(%{email: "auth2@test.com", password: "password123"})
      assert {:error, :unauthorized} = Auth.authenticate("auth2@test.com", "wrongpass")
    end

    test "authenticate/2 with non-existent email returns error" do
      assert {:error, :unauthorized} = Auth.authenticate("nonexistent@test.com", "password123")
    end
  end
end
