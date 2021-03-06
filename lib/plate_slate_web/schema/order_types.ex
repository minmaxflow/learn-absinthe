defmodule PlateSlateWeb.Schema.OrderingTypes do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers
  alias PlateSlateWeb.Schema.Middleware

  input_object :order_item_input do
    field(:menu_item_id, non_null(:id))
    field(:quantity, non_null(:integer))
  end

  input_object :place_order_input do
    field(:customer_number, :integer)
    field(:items, non_null(list_of(non_null(:order_item_input))))
  end

  object :order do
    field(:id, :id)
    field(:customer_number, :integer)
    field(:items, list_of(:order_item))
    field(:state, :string)
  end

  object :order_item do
    field(:name, :string)
    field(:quantity, :integer)
  end

  object :order_mutations do
    field :place_order, :order do
      arg(:input, non_null(:place_order_input))
      middleware(Middleware.Authorize, :any)
      resolve(&Resolvers.Ordering.place_order/3)
    end

    field :ready_order, :order do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Ordering.ready_order/3)
    end

    field :complete_order, :order do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Ordering.complete_order/3)
    end
  end

  object :order_subscription do
    # 放在schema里面了

    # field :new_order, :order do
    #   config(fn _args, _info ->
    #     {:ok, topic: "*"}
    #   end)

    #   resolve(fn root, _, _ ->
    #     IO.inspect(root)
    #     {:ok, root}
    #   end)
    # end
  end
end
