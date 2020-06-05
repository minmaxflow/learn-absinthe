defmodule PlateSlate.Ordering.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias PlateSlate.Ordering.Order
  alias PlateSlate.Accounts.User

  schema "orders" do
    field(:customer_number, :integer, read_after_writes: true)
    field(:ordered_at, :utc_datetime, read_after_writes: true)
    field(:state, :string, read_after_wirtes: true)

    belongs_to(:customer, User)

    embeds_many(:items, PlateSlate.Ordering.Item)

    timestamps()
  end

  @doc false
  def changeset(%Order{} = order, attrs) do
    order
    |> cast(attrs, [:customer_number, :ordered_at, :state, :customer_id])
    |> cast_embed(:items)
  end
end
