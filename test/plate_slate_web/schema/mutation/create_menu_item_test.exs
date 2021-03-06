defmodule PlateSlateWeb.Schema.Mutation.CreateMenuTest do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.{Repo, Menu, Item}
  import Ecto.Query

  setup do
    PlateSlate.Seeds.run()

    category_id =
      from(t in Menu.Category, where: t.name == "Sandwiches")
      |> Repo.one!()
      |> Map.fetch!(:id)
      |> to_string

    {:ok, category_id: category_id}
  end

  @query """
  mutation ($menuItem: MenuItemInput!) {
    menuItem: createMenuItem(input: $menuItem) {
      name
      description
      price
    }
  }
  """

  test "createMenuItem field creates an item", %{conn: conn, category_id: category_id} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }

    user = Factory.create_user("employee")
    conn = build_conn() |> auth_user(user)

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{"menuItem" => menu_item}
      )

    assert json_response(conn, 200) == %{
             "data" => %{
               "menuItem" => %{
                 "name" => menu_item["name"],
                 "description" => menu_item["description"],
                 "price" => menu_item["price"]
               }
             }
           }
  end

  test "creating a menu item with an existing name fails",
       %{conn: conn, category_id: category_id} do
    menu_item = %{
      "name" => "Reuben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }

    user = Factory.create_user("employee")
    conn = build_conn() |> auth_user(user)

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{"menuItem" => menu_item}
      )

    assert %{
             "data" => %{"menuItem" => nil},
             "errors" => [
               %{
                 "message" => "changeset errors",
                 "path" => ["menuItem"],
                 "details" => %{"name" => ["has already been taken"]}
               }
             ]
           } = json_response(conn, 200) |> IO.inspect()
  end

  test "must be authorized as an employee to do menu item creation",
       %{category_id: category_id} do
    menu_item = %{
      "name" => "Reuben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => category_id
    }

    user = Factory.create_user("customer")
    conn = build_conn() |> auth_user(user)

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{"menuItem" => menu_item}
      )

    assert json_response(conn, 200) == %{
             "data" => %{"menuItem" => nil},
             "errors" => [
               %{
                 "locations" => [%{"column" => 0, "line" => 2}],
                 "message" => "unauthorized",
                 "path" => ["menuItem"]
               }
             ]
           }
  end

  defp auth_user(conn, user) do
    token = PlateSlateWeb.Authentication.sign(%{role: user.role, id: user.id})
    put_req_header(conn, "authorization", "Bearer #{token}")
  end
end
