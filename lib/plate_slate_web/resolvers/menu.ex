defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.Menu

  alias PlateSlate.Repo

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def item_for_category(category, _, _) do
    query = Ecto.assoc(category, :items)
    {:ok, Repo.all(query)}
  end

  def category_for_item(menu_item, _, _) do
    query = Ecto.assoc(menu_item, :category)
    {:ok, Repo.one(query)}
  end

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end

  def create_item(_, %{input: params}, _) do
    Menu.create_item(params)
  end
end
