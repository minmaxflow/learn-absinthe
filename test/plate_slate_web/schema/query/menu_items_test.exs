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
    menuItems(filter: {name: "reu"}) {
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
    menuItems(filter: {name: 123}) {
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
  end

  @query """
  query ($term: String) {
    menuItems(filter: {name: $term}) {
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

  @query """
  {
    menuItems(order: DESC) {
      name
    }
  }
  """
  test "menuItems field returns items descending using literals", %{conn: conn} do
    conn = get(conn, "/api", query: @query)

    assert %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Water"} | _
               ]
             }
           } = json_response(conn, 200)
  end

  @query """
  query ($order: SortOrder!) {
    menuItems(order: $order) {
      name
    }
  }
  """
  @variables %{"order" => "DESC"}
  test "menuItems field returns items desending using variables", %{conn: conn} do
    conn = get(conn, "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Water"} | _
               ]
             }
           } = json_response(conn, 200)
  end

  @query """
  {
    menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}) {
      name
    }
  }
  """
  test "menuItems field returns menuItems, filtering with a literal" do
    conn = get(build_conn(), "/api", query: @query)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
           } == json_response(conn, 200)
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
    }
  }
  """
  @variables %{"filter" => %{"tag" => "Vegetarian", "category" => "Sandwiches"}}
  test "menuItems field returns menuItems, filtering with a variable" do
    conn = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
           } == json_response(conn, 200)
  end
end
