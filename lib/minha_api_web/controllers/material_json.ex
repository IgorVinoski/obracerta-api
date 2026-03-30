defmodule MinhaApiWeb.MaterialJSON do
  alias MinhaApi.Construcao.Material

  @doc """
  Renders a list of materiais.
  """
  def index(%{materiais: materiais}) do
    %{data: for(material <- materiais, do: data(material))}
  end

  @doc """
  Renders a single material.
  """
  def show(%{material: material}) do
    %{data: data(material)}
  end

  defp data(%Material{} = material) do
    %{
      id: material.id,
      nome: material.nome,
      descricao: material.descricao,
      quantidade: material.quantidade,
      unidade: material.unidade,
      custo_unitario: material.custo_unitario,
      obra_id: material.obra_id
    }
  end
end
