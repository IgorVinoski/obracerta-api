defmodule MinhaApi.Repo.Migrations.CreateObras do
  use Ecto.Migration

  def change do
    create table(:obras) do
      add :titulo, :string
      add :endereco, :string
      add :descricao, :text
      add :status, :string
      add :orcamento, :float
      add :data_inicio, :date
      add :data_fim, :date

      timestamps(type: :utc_datetime)
    end
  end
end
