defmodule MinhaApiWeb.EtapaJSON do
  alias MinhaApi.Construcao.Etapa

  @doc """
  Renders a list of etapas.
  """
  def index(%{etapas: etapas}) do
    %{data: for(etapa <- etapas, do: data(etapa))}
  end

  @doc """
  Renders a single etapa.
  """
  def show(%{etapa: etapa}) do
    %{data: data(etapa)}
  end

  defp data(%Etapa{} = etapa) do
    %{
      id: etapa.id,
      titulo: etapa.titulo,
      descricao: etapa.descricao,
      status: etapa.status,
      ordem: etapa.ordem,
      obra_id: etapa.obra_id
    }
  end
end
