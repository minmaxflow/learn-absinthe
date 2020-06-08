# ---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
# ---
defmodule PlateSlateWeb.Schema.Subscription.NewOrderTest do
  use PlateSlateWeb.SubscriptionCase

  @login """
  mutation ($email: String!, $role: Role!) {
    login(role: $role, password: "super-secret", email: $email) {
      token
    }
  }
  """
  @subscription """
  subscription {
    newOrder {
      customerNumber
    }
  }
  """
  @mutation """
  mutation ($input: PlaceOrderInput!) {
    placeOrder(input: $input) {id}
  }
  """
  test "new orders can be subscribed to", %{socket: socket} do
    user = Factory.create_user("employee")

    ref =
      push_doc(socket, @login,
        variables: %{
          "email" => user.email,
          "role" => "EMPLOYEE"
        }
      )

    assert_reply(ref, :ok, %{data: %{"login" => %{"token" => _}}}, 1000)

    # setup a subscription
    ref = push_doc(socket, @subscription)
    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    # run a mutation to trigger the subscription
    order_input = %{
      "customerNumber" => 24,
      "items" => [%{"quantity" => 2, "menuItemId" => menu_item("Reuben").id}]
    }

    ref = push_doc(socket, @mutation, variables: %{"input" => order_input})
    assert_reply(ref, :ok, reply)
    assert %{data: %{"placeOrder" => %{"id" => _}}} = reply

    # check to see if we got subscription data
    expected = %{
      result: %{data: %{"newOrder" => %{"customerNumber" => 24}}},
      subscriptionId: subscription_id
    }

    assert_push("subscription:data", push)
    assert expected == push
  end
end
