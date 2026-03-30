defmodule MinhaApi.Construcao.Etapa do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_statuses ~w(pendente em_andamento concluida)

  schema "etapas" do
    field :titulo, :string
    field :descricao, :string
    field :status, :string
    field :ordem, :integer

    belongs_to :obra, MinhaApi.Construcao.Obra

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(etapa, attrs) do
    etapa
    |> cast(attrs, [:titulo, :descricao, :status, :ordem, :obra_id])
    |> validate_required([:titulo, :status, :ordem, :obra_id])
    |> validate_inclusion(:status, @valid_statuses,
      message: "must be one of: #{Enum.join(@valid_statuses, ", ")}"
    )
    |> assoc_constraint(:obra)
  end
end
