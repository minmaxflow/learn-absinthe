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

  import_types(__MODULE__.MenuTypes)
  import_types(__MODULE__.OrderingTypes)

  alias PlateSlate.Ordering.Order

  alias PlateSlateWeb.Schema.Middleware

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end

  query do
    import_fields(:menu_queries)
  end

  mutation do
    import_fields(:menu_mutations)
    import_fields(:order_mutations)
  end

  subscription do
    # 不行，不知道原因
    # import_field(:order_subscription)

    field :update_order, :order do
      arg(:id, non_null(:id))

      config(fn args, _info ->
        {:ok, topic: args.id}
      end)

      trigger([:ready_order, :complete_order],
        topic: fn
          %Order{} = order -> [order.id]
          _ -> []
        end
      )

      resolve(fn %Order{} = order, _, _ ->
        {:ok, order}
      end)
    end

    # Other fields

    field :new_order, :order do
      config(fn _args, _info ->
        {:ok, topic: "*"}
      end)

      resolve(fn root, _, _ ->
        {:ok, root}
      end)
    end
  end

  enum :sort_order do
    value(:asc)
    value(:desc)
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

  # 看样子，定义scalar的parse是有可以有1个或者2个参数的方法
  scalar :decimal do
    parse(fn
      %{value: value}, _ ->
        Decimal.parse(value)

      _, _ ->
        :error
    end)

    serialize(&to_string/1)
  end
end
