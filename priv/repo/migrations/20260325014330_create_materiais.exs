defmodule MinhaApi.Repo.Migrations.CreateMateriais do
  use Ecto.Migration

  def change do
    create table(:materiais) do
      add :nome, :string
      add :descricao, :text
      add :quantidade, :float
      add :unidade, :string
      add :custo_unitario, :float
      add :obra_id, references(:obras, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:materiais, [:obra_id])
  end
end
