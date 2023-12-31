defmodule LiveNavWeb.HomeLive do
  use LiveNavWeb, :live_view
  alias LiveNavWeb.{P1, P2, P3}

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    active = "bg-[bisque] text-[midnightblue] px-1 py-1"

    socket =
      socket
      |> Phoenix.Component.assign_new(:menu, fn ->
        [
          {"Home", Phoenix.VerifiedRoutes.path(socket, LiveNavWeb.Router, ~p"/"), ""},
          {"Page 1",
           Phoenix.VerifiedRoutes.unverified_path(socket, LiveNavWeb.Router, "/?page=p1"), "p1"},
          {"Page 2", "/?page=p2", "p2"}
        ]
      end)
      |> assign(:active, active)
      |> assign(:count, 0)
      |> assign(:p2_count, 0)

    {:ok, socket}
  end

  @impl true

  def render(%{current_path: "p1"} = assigns) do
    ~H"""
    <.live_component module={P1} id={1} lc_count={@count} />
    """
  end

  def render(%{current_path: "p2"} = assigns) do
    ~H"""
    <.live_component module={P2} id={2} lc_count={@count} />
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Home page</h1>
      <.button id="lv_inc" type="button" phx-click="update_count">Inc</.button>
      <p>The counter: <%= @count %></p>
      <p>The counter from page 2: <%= @p2_count %></p>

      <hr />
      <.live_component module={P3} id={3} />
    </div>
    """
  end

  @impl true
  def handle_event("update_count", _p, socket) do
    Task.start(fn ->
      Phoenix.LiveView.send_update(self(), LiveNavWeb.P3,
        id: 3,
        update_count: socket.assigns.count + 1
      )
    end)

    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  @impl true
  def handle_params(%{"page" => page}, _uri, socket) do
    {:noreply, assign(socket, :current_path, page)}
  end

  # first pass "/"
  def handle_params(_p, _uri, socket) do
    {:noreply, assign(socket, :current_path, "")}
  end

  @impl true
  def handle_info({:p2_count, v}, socket) do
    IO.inspect(v)
    {:noreply, assign(socket, :p2_count, v)}
  end
end
