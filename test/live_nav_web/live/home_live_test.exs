defmodule LiveNavWeb.HomeLiveTest do
  import Phoenix.LiveViewTest
  use LiveNavWeb.ConnCase

  test "renders Home page", %{conn: conn} do
    {:ok, _, html} = live(conn, "/")

    assert html =~ "Home page"
  end

  test "button inc on LV", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> element("button#lv_inc")
           |> render_click() =~
             "The counter: 1"
  end

  test "receive from page2", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    send(view.pid, {:p2_count, 2})
    assert render(view) =~ "<p>The counter from page 2: 2</p>"
  end

  test "assert the rendered embedded LC3 has incremented counter when clicked in the LV", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, "/")
    view |> element("button", "Inc") |> render_click()
    assert render_component(LiveNavWeb.P3, id: 3, update_count: 1)
  end

  test "render navigation to LC1", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_patch(view, "?page=p1") =~ "<h1>Page 1</h1>"
  end

  test "render navigation to LC2", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert render_patch(view, "?page=p2") =~ "<h1>Page 2</h1>"
  end

  test "assert counter in page 1 is incremented when clicked in the LV", %{conn: conn} do
    {:ok, view, _} = live(conn, "/")
    view |> element("button#lv_inc") |> render_click()
    assert render_patch(view, "?page=p1") =~ "<p>Updated count: 1</p>"
  end

  test "test counter in page 2", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/?page=p2")

    assert view
           |> element("button#lc2_inc")
           |> render_click() =~
             "<p>Page 2 count: 1</p>"
  end
end
