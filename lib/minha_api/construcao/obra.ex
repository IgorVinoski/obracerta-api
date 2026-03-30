defmodule MinhaApi.Construcao.Obra do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_statuses ~w(planejamento em_andamento concluida pausada)

  schema "obras" do
    field :titulo, :string
    field :endereco, :string
    field :descricao, :string
    field :status, :string
    field :orcamento, :float
    field :data_inicio, :date
    field :data_fim, :date

    has_many :etapas, MinhaApi.Construcao.Etapa
    has_many :materiais, MinhaApi.Construcao.Material

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(obra, attrs) do
    obra
    |> cast(attrs, [:titulo, :endereco, :descricao, :status, :orcamento, :data_inicio, :data_fim])
    |> validate_required([:titulo, :endereco, :status, :orcamento, :data_inicio])
    |> validate_inclusion(:status, @valid_statuses,
      message: "must be one of: #{Enum.join(@valid_statuses, ", ")}"
    )
  end
end
