defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Matching a name"
    field(:name, :string)

    @desc "Matching a category name"
    field(:category, :string)

    # field :category, non_null(:string)

    @desc "Matching a tag"
    field(:tag, :string)

    @desc "price above"
    field(:priced_above, :float)

    @desc "price below"
    field(:priced_below, :float)

    @desc "Added to the menu before this date"
    field(:added_before, :date)

    @desc "Added to the menu after this date"
    field(:added_after, :date)
  end

  @desc "object menu item"
  object :menu_item do
    @desc "id"
    field(:id, :id)

    @desc "name"
    field(:name, non_null(:string))

    @desc "description"
    field(:description, :string)

    field(:added_on, :date)
  end

  object :menu_queries do
    @desc "The list of available on items on the menu"
    field(:menu_items, list_of(:menu_item)) do
      arg(:filter, :menu_item_filter)

      # arg(:order, :sort_order)
      arg(:order, type: :sort_order, default_value: :asc)

      resolve(&Resolvers.Menu.menu_items/3)
    end
  end
end
