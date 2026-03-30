defmodule MinhaApiWeb.ObraJSON do
  alias MinhaApi.Construcao.Obra

  @doc """
  Renders a list of obras.
  """
  def index(%{obras: obras}) do
    %{data: for(obra <- obras, do: data(obra))}
  end

  @doc """
  Renders a single obra.
  """
  def show(%{obra: obra}) do
    %{data: data(obra)}
  end

  defp data(%Obra{} = obra) do
    %{
      id: obra.id,
      titulo: obra.titulo,
      endereco: obra.endereco,
      descricao: obra.descricao,
      status: obra.status,
      orcamento: obra.orcamento,
      data_inicio: obra.data_inicio,
      data_fim: obra.data_fim
    }
  end
end
