defmodule MinhaApi.Construcao do
  @moduledoc """
  The Construcao context.
  """

  import Ecto.Query, warn: false
  alias MinhaApi.Repo

  alias MinhaApi.Construcao.Obra

  @doc """
  Returns the list of obras.

  ## Examples

      iex> list_obras()
      [%Obra{}, ...]

  """
  def list_obras do
    Repo.all(Obra)
  end

  @doc """
  Gets a single obra.

  Raises `Ecto.NoResultsError` if the Obra does not exist.

  ## Examples

      iex> get_obra!(123)
      %Obra{}

      iex> get_obra!(456)
      ** (Ecto.NoResultsError)

  """
  def get_obra!(id), do: Repo.get!(Obra, id)

  @doc """
  Creates a obra.

  ## Examples

      iex> create_obra(%{field: value})
      {:ok, %Obra{}}

      iex> create_obra(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_obra(attrs) do
    %Obra{}
    |> Obra.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a obra.

  ## Examples

      iex> update_obra(obra, %{field: new_value})
      {:ok, %Obra{}}

      iex> update_obra(obra, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_obra(%Obra{} = obra, attrs) do
    obra
    |> Obra.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a obra.

  ## Examples

      iex> delete_obra(obra)
      {:ok, %Obra{}}

      iex> delete_obra(obra)
      {:error, %Ecto.Changeset{}}

  """
  def delete_obra(%Obra{} = obra) do
    Repo.delete(obra)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking obra changes.

  ## Examples

      iex> change_obra(obra)
      %Ecto.Changeset{data: %Obra{}}

  """
  def change_obra(%Obra{} = obra, attrs \\ %{}) do
    Obra.changeset(obra, attrs)
  end

  alias MinhaApi.Construcao.Etapa

  @doc """
  Returns the list of etapas.

  ## Examples

      iex> list_etapas()
      [%Etapa{}, ...]

  """
  def list_etapas do
    Repo.all(Etapa)
  end

  @doc """
  Gets a single etapa.

  Raises `Ecto.NoResultsError` if the Etapa does not exist.

  ## Examples

      iex> get_etapa!(123)
      %Etapa{}

      iex> get_etapa!(456)
      ** (Ecto.NoResultsError)

  """
  def get_etapa!(id), do: Repo.get!(Etapa, id)

  @doc """
  Creates a etapa.

  ## Examples

      iex> create_etapa(%{field: value})
      {:ok, %Etapa{}}

      iex> create_etapa(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_etapa(attrs) do
    %Etapa{}
    |> Etapa.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a etapa.

  ## Examples

      iex> update_etapa(etapa, %{field: new_value})
      {:ok, %Etapa{}}

      iex> update_etapa(etapa, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_etapa(%Etapa{} = etapa, attrs) do
    etapa
    |> Etapa.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a etapa.

  ## Examples

      iex> delete_etapa(etapa)
      {:ok, %Etapa{}}

      iex> delete_etapa(etapa)
      {:error, %Ecto.Changeset{}}

  """
  def delete_etapa(%Etapa{} = etapa) do
    Repo.delete(etapa)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking etapa changes.

  ## Examples

      iex> change_etapa(etapa)
      %Ecto.Changeset{data: %Etapa{}}

  """
  def change_etapa(%Etapa{} = etapa, attrs \\ %{}) do
    Etapa.changeset(etapa, attrs)
  end

  alias MinhaApi.Construcao.Material

  @doc """
  Returns the list of materiais.

  ## Examples

      iex> list_materiais()
      [%Material{}, ...]

  """
  def list_materiais do
    Repo.all(Material)
  end

  @doc """
  Gets a single material.

  Raises `Ecto.NoResultsError` if the Material does not exist.

  ## Examples

      iex> get_material!(123)
      %Material{}

      iex> get_material!(456)
      ** (Ecto.NoResultsError)

  """
  def get_material!(id), do: Repo.get!(Material, id)

  @doc """
  Creates a material.

  ## Examples

      iex> create_material(%{field: value})
      {:ok, %Material{}}

      iex> create_material(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_material(attrs) do
    %Material{}
    |> Material.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a material.

  ## Examples

      iex> update_material(material, %{field: new_value})
      {:ok, %Material{}}

      iex> update_material(material, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_material(%Material{} = material, attrs) do
    material
    |> Material.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a material.

  ## Examples

      iex> delete_material(material)
      {:ok, %Material{}}

      iex> delete_material(material)
      {:error, %Ecto.Changeset{}}

  """
  def delete_material(%Material{} = material) do
    Repo.delete(material)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking material changes.

  ## Examples

      iex> change_material(material)
      %Ecto.Changeset{data: %Material{}}

  """
  def change_material(%Material{} = material, attrs \\ %{}) do
    Material.changeset(material, attrs)
  end
end
