defmodule MinhaApi.ConstrucaoTest do
  use MinhaApi.DataCase

  alias MinhaApi.Construcao

  describe "obras" do
    alias MinhaApi.Construcao.Obra

    import MinhaApi.ConstrucaoFixtures

    @invalid_attrs %{status: nil, titulo: nil, endereco: nil, descricao: nil, orcamento: nil, data_inicio: nil, data_fim: nil}

    test "list_obras/0 returns all obras" do
      obra = obra_fixture()
      assert Construcao.list_obras() == [obra]
    end

    test "get_obra!/1 returns the obra with given id" do
      obra = obra_fixture()
      assert Construcao.get_obra!(obra.id) == obra
    end

    test "create_obra/1 with valid data creates a obra" do
      valid_attrs = %{status: "planejamento", titulo: "some titulo", endereco: "some endereco", descricao: "some descricao", orcamento: 120.5, data_inicio: ~D[2026-03-24], data_fim: ~D[2026-03-24]}

      assert {:ok, %Obra{} = obra} = Construcao.create_obra(valid_attrs)
      assert obra.status == "planejamento"
      assert obra.titulo == "some titulo"
      assert obra.endereco == "some endereco"
      assert obra.descricao == "some descricao"
      assert obra.orcamento == 120.5
      assert obra.data_inicio == ~D[2026-03-24]
      assert obra.data_fim == ~D[2026-03-24]
    end

    test "create_obra/1 with invalid status returns error changeset" do
      attrs = %{status: "invalid_status", titulo: "titulo", endereco: "endereco", orcamento: 100.0, data_inicio: ~D[2026-01-01]}
      assert {:error, %Ecto.Changeset{} = changeset} = Construcao.create_obra(attrs)
      assert %{status: _} = errors_on(changeset)
    end

    test "create_obra/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Construcao.create_obra(@invalid_attrs)
    end

    test "update_obra/2 with valid data updates the obra" do
      obra = obra_fixture()
      update_attrs = %{status: "em_andamento", titulo: "some updated titulo", endereco: "some updated endereco", descricao: "some updated descricao", orcamento: 456.7, data_inicio: ~D[2026-03-25], data_fim: ~D[2026-03-25]}

      assert {:ok, %Obra{} = obra} = Construcao.update_obra(obra, update_attrs)
      assert obra.status == "em_andamento"
      assert obra.titulo == "some updated titulo"
      assert obra.endereco == "some updated endereco"
      assert obra.descricao == "some updated descricao"
      assert obra.orcamento == 456.7
      assert obra.data_inicio == ~D[2026-03-25]
      assert obra.data_fim == ~D[2026-03-25]
    end

    test "update_obra/2 with invalid data returns error changeset" do
      obra = obra_fixture()
      assert {:error, %Ecto.Changeset{}} = Construcao.update_obra(obra, @invalid_attrs)
      assert obra == Construcao.get_obra!(obra.id)
    end

    test "delete_obra/1 deletes the obra" do
      obra = obra_fixture()
      assert {:ok, %Obra{}} = Construcao.delete_obra(obra)
      assert_raise Ecto.NoResultsError, fn -> Construcao.get_obra!(obra.id) end
    end

    test "change_obra/1 returns a obra changeset" do
      obra = obra_fixture()
      assert %Ecto.Changeset{} = Construcao.change_obra(obra)
    end
  end

  describe "etapas" do
    alias MinhaApi.Construcao.Etapa

    import MinhaApi.ConstrucaoFixtures

    @invalid_attrs %{status: nil, titulo: nil, descricao: nil, ordem: nil}

    test "list_etapas/0 returns all etapas" do
      etapa = etapa_fixture()
      assert Construcao.list_etapas() == [etapa]
    end

    test "get_etapa!/1 returns the etapa with given id" do
      etapa = etapa_fixture()
      assert Construcao.get_etapa!(etapa.id) == etapa
    end

    test "create_etapa/1 with valid data creates a etapa" do
      obra = obra_fixture()
      valid_attrs = %{status: "pendente", titulo: "some titulo", descricao: "some descricao", ordem: 42, obra_id: obra.id}

      assert {:ok, %Etapa{} = etapa} = Construcao.create_etapa(valid_attrs)
      assert etapa.status == "pendente"
      assert etapa.titulo == "some titulo"
      assert etapa.descricao == "some descricao"
      assert etapa.ordem == 42
      assert etapa.obra_id == obra.id
    end

    test "create_etapa/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Construcao.create_etapa(@invalid_attrs)
    end

    test "create_etapa/1 with invalid status returns error changeset" do
      obra = obra_fixture()
      attrs = %{status: "invalid", titulo: "titulo", ordem: 1, obra_id: obra.id}
      assert {:error, %Ecto.Changeset{} = changeset} = Construcao.create_etapa(attrs)
      assert %{status: _} = errors_on(changeset)
    end

    test "update_etapa/2 with valid data updates the etapa" do
      etapa = etapa_fixture()
      update_attrs = %{status: "em_andamento", titulo: "some updated titulo", descricao: "some updated descricao", ordem: 43}

      assert {:ok, %Etapa{} = etapa} = Construcao.update_etapa(etapa, update_attrs)
      assert etapa.status == "em_andamento"
      assert etapa.titulo == "some updated titulo"
      assert etapa.descricao == "some updated descricao"
      assert etapa.ordem == 43
    end

    test "update_etapa/2 with invalid data returns error changeset" do
      etapa = etapa_fixture()
      assert {:error, %Ecto.Changeset{}} = Construcao.update_etapa(etapa, @invalid_attrs)
      assert etapa == Construcao.get_etapa!(etapa.id)
    end

    test "delete_etapa/1 deletes the etapa" do
      etapa = etapa_fixture()
      assert {:ok, %Etapa{}} = Construcao.delete_etapa(etapa)
      assert_raise Ecto.NoResultsError, fn -> Construcao.get_etapa!(etapa.id) end
    end

    test "change_etapa/1 returns a etapa changeset" do
      etapa = etapa_fixture()
      assert %Ecto.Changeset{} = Construcao.change_etapa(etapa)
    end
  end

  describe "materiais" do
    alias MinhaApi.Construcao.Material

    import MinhaApi.ConstrucaoFixtures

    @invalid_attrs %{nome: nil, descricao: nil, quantidade: nil, unidade: nil, custo_unitario: nil}

    test "list_materiais/0 returns all materiais" do
      material = material_fixture()
      assert Construcao.list_materiais() == [material]
    end

    test "get_material!/1 returns the material with given id" do
      material = material_fixture()
      assert Construcao.get_material!(material.id) == material
    end

    test "create_material/1 with valid data creates a material" do
      obra = obra_fixture()
      valid_attrs = %{nome: "some nome", descricao: "some descricao", quantidade: 120.5, unidade: "some unidade", custo_unitario: 120.5, obra_id: obra.id}

      assert {:ok, %Material{} = material} = Construcao.create_material(valid_attrs)
      assert material.nome == "some nome"
      assert material.descricao == "some descricao"
      assert material.quantidade == 120.5
      assert material.unidade == "some unidade"
      assert material.custo_unitario == 120.5
      assert material.obra_id == obra.id
    end

    test "create_material/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Construcao.create_material(@invalid_attrs)
    end

    test "create_material/1 validates quantidade must be positive" do
      obra = obra_fixture()
      attrs = %{nome: "nome", quantidade: -1.0, unidade: "kg", custo_unitario: 10.0, obra_id: obra.id}
      assert {:error, %Ecto.Changeset{} = changeset} = Construcao.create_material(attrs)
      assert %{quantidade: _} = errors_on(changeset)
    end

    test "update_material/2 with valid data updates the material" do
      material = material_fixture()
      update_attrs = %{nome: "some updated nome", descricao: "some updated descricao", quantidade: 456.7, unidade: "some updated unidade", custo_unitario: 456.7}

      assert {:ok, %Material{} = material} = Construcao.update_material(material, update_attrs)
      assert material.nome == "some updated nome"
      assert material.descricao == "some updated descricao"
      assert material.quantidade == 456.7
      assert material.unidade == "some updated unidade"
      assert material.custo_unitario == 456.7
    end

    test "update_material/2 with invalid data returns error changeset" do
      material = material_fixture()
      assert {:error, %Ecto.Changeset{}} = Construcao.update_material(material, @invalid_attrs)
      assert material == Construcao.get_material!(material.id)
    end

    test "delete_material/1 deletes the material" do
      material = material_fixture()
      assert {:ok, %Material{}} = Construcao.delete_material(material)
      assert_raise Ecto.NoResultsError, fn -> Construcao.get_material!(material.id) end
    end

    test "change_material/1 returns a material changeset" do
      material = material_fixture()
      assert %Ecto.Changeset{} = Construcao.change_material(material)
    end
  end
end
