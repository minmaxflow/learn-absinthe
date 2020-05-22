defmodule PlateSlateWeb.Schema.Query.MenuItemTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  {
    menuItems {
      name
    }
  }
  """
  test "menuItems field retusn menu items", %{conn: conn} do
    conn = get(conn, "/api", query: @query)

    assert %{
             "data" => %{
               "menuItems" => [_ | _]
             }
           } = json_response(conn, 200)
  end
end
