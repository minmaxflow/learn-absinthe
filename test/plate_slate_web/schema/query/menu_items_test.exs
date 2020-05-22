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

  @query """
  {
    menuItems(matching: "reu") {
      name
    }
  }
  """
  test "menuItems field retuns menu items filtered by name", %{conn: conn} do
    conn = get(conn, "/api", query: @query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
  {
    menuItems(matching: 123) {
      name
    }
  }
  """
  test "menuItems field returns errors when using a bad value" do
    conn = get(conn, "/api", query: @query)

    assert %{
             "errors" => [
               %{"message" => message}
             ]
           } = json_response(conn, 400)

    assert message =~ ~s|"matching" has invalid value 123|
  end

  @query """
  query ($term: String) {
    menuItems(matching: $term) {
      name
    }
  }
  """
  @variables %{"term" => "reu"}
  test "menuItems field filters by name when using a variable", %{conn: conn} do
    conn = get(conn, "/api", query: @query, variables: @variables)

    assert json_response(conn, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end
end
