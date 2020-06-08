defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers
  alias PlateSlate.Menu.{Item, Category}
  alias PlateSlateWeb.Schema.Middleware

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

  input_object :menu_item_input do
    field(:name, non_null(:string))
    field(:description, :string)
    field(:price, non_null(:decimal))
    field(:category_id, non_null(:id))
  end

  @desc "object menu item"
  object :menu_item do
    interfaces([:search_result])

    @desc "id"
    field(:id, :id)

    @desc "name"
    field(:name, :string)
    # non_null会和 interface :search_result 类型不一致
    # field(:name, non_null(:string))

    @desc "description"
    field(:description, :string)

    field(:price, :decimal)

    field(:added_on, :date)

    field(:allergy_info, list_of(:allergy_info))

    field :category, :category do
      resolve(&Resolvers.Menu.category_for_item/3)
    end
  end

  object :allergy_info do
    field(:allergen, :string)
    field(:severity, :string)
  end

  object :category do
    interfaces([:search_result])

    field(:name, :string)
    field(:description, :string)

    field :items, list_of(:menu_item) do
      resolve(&Resolvers.Menu.item_for_category/3)
    end
  end

  union :search_result_old do
    types([:menu_item, :category])

    resolve_type(fn
      %Item{}, _ -> :menu_item
      %Category{}, _ -> :category
      _, _ -> nil
    end)
  end

  interface :search_result do
    field(:name, :string)

    resolve_type(fn
      %Item{}, _ -> :menu_item
      %Category{}, _ -> :category
      _, _ -> nil
    end)
  end

  object :menu_queries do
    @desc "The list of available on items on the menu"
    field(:menu_items, list_of(:menu_item)) do
      arg(:filter, :menu_item_filter)

      # arg(:order, :sort_order)
      arg(:order, type: :sort_order, default_value: :asc)

      resolve(&Resolvers.Menu.menu_items/3)
    end

    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      resolve(&Resolvers.Menu.search/3)
    end
  end

  object :menu_mutations do
    field :create_menu_item, :menu_item do
      arg(:input, non_null(:menu_item_input))
      middleware(Middleware.Authorize, "employee")
      resolve(&Resolvers.Menu.create_item/3)
    end
  end
end
