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

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end

  def create_item(_, %{input: params}, %{context: context}) do
    case context do
      %{current_user: %{role: "employee"}} ->
        Menu.create_item(params)

      _ ->
        {:error, "unauthorized"}
    end
  end
end
