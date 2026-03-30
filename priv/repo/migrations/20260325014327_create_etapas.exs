defmodule MinhaApi.Repo.Migrations.CreateEtapas do
  use Ecto.Migration

  def change do
    create table(:etapas) do
      add :titulo, :string
      add :descricao, :text
      add :status, :string
      add :ordem, :integer
      add :obra_id, references(:obras, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:etapas, [:obra_id])
  end
end
