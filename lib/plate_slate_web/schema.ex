# ---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
# ---
defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  alias PlateSlateWeb.Resolvers

  query do
    @desc "The list of available on items on the menu"
    field(:menu_items, list_of(:menu_item)) do
      arg(:filter, :menu_item_filter)

      # arg(:order, :sort_order)
      arg(:order, type: :sort_order, default_value: :asc)

      resolve(&Resolvers.Menu.menu_items/3)
    end
  end

  enum :sort_order do
    value(:asc)
    value(:desc)
  end

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

  scalar :date do
    parse(fn input ->
      # case Date.from_iso8601(input.value) do
      #   {:ok, date} -> {:ok, date}
      #   _ -> :error
      # end

      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           {:ok, date} <- Date.from_iso8601(value) do
        {:ok, date}
      else
        _ -> :error
      end
    end)

    serialize(fn date ->
      Date.to_iso8601(date)
    end)
  end
end
