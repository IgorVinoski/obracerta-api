defmodule MinhaApi.Construcao.Material do
  use Ecto.Schema
  import Ecto.Changeset

  schema "materiais" do
    field :nome, :string
    field :descricao, :string
    field :quantidade, :float
    field :unidade, :string
    field :custo_unitario, :float

    belongs_to :obra, MinhaApi.Construcao.Obra

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(material, attrs) do
    material
    |> cast(attrs, [:nome, :descricao, :quantidade, :unidade, :custo_unitario, :obra_id])
    |> validate_required([:nome, :quantidade, :unidade, :custo_unitario, :obra_id])
    |> validate_number(:quantidade, greater_than: 0, message: "must be greater than 0")
    |> validate_number(:custo_unitario, greater_than_or_equal_to: 0, message: "must be >= 0")
    |> assoc_constraint(:obra)
  end
end
