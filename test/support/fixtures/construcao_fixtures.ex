defmodule MinhaApi.ConstrucaoFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MinhaApi.Construcao` context.
  """

  @doc """
  Generate a obra.
  """
  def obra_fixture(attrs \\ %{}) do
    {:ok, obra} =
      attrs
      |> Enum.into(%{
        data_fim: ~D[2026-03-24],
        data_inicio: ~D[2026-03-24],
        descricao: "some descricao",
        endereco: "some endereco",
        orcamento: 120.5,
        status: "planejamento",
        titulo: "some titulo"
      })
      |> MinhaApi.Construcao.create_obra()

    obra
  end

  @doc """
  Generate a etapa.
  """
  def etapa_fixture(attrs \\ %{}) do
    obra = obra_fixture()

    {:ok, etapa} =
      attrs
      |> Enum.into(%{
        descricao: "some descricao",
        ordem: 42,
        status: "pendente",
        titulo: "some titulo",
        obra_id: obra.id
      })
      |> MinhaApi.Construcao.create_etapa()

    etapa
  end

  @doc """
  Generate a material.
  """
  def material_fixture(attrs \\ %{}) do
    obra = obra_fixture()

    {:ok, material} =
      attrs
      |> Enum.into(%{
        custo_unitario: 120.5,
        descricao: "some descricao",
        nome: "some nome",
        quantidade: 120.5,
        unidade: "some unidade",
        obra_id: obra.id
      })
      |> MinhaApi.Construcao.create_material()

    material
  end
end
