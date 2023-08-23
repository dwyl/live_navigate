defmodule LiveNavWeb.HomeLive do
  use LiveNavWeb, :live_view
  alias LiveNavWeb.{P1, P2, P3}
  alias LiveNav.StreamSymbolSup

  require Logger
  @symbol "ethereum"
  @topic "price"

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
          {"Page 2", "/?page=p2", "p2"},
          {"Page 3", "/?page=p3", "p3"}
        ]
      end)
      |> assign_new(:active, fn -> active end)
      |> assign_new(:count, fn -> 0 end)
      |> assign_new(:price_update, fn -> nil end)

    {:ok, socket}
  end

  @impl true
  def render(%{current_path: "p1"} = assigns) do
    ~H"""
    <.live_component module={P1} id={1} lc_count={@count} price_update={@price_update} />
    """
  end

  def render(%{current_path: "p2"} = assigns) do
    ~H"""
    <.live_component module={P2} id={2} lc_count={@count} />
    """
  end

  def render(%{current_path: "p3"} = assigns) do
    ~H"""
    <.live_component module={P3} id={3} lc_count={@count} />
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Home page</h1>
      <p>
        <.button type="button" phx-click="stream">Stream!</.button>
      </p>
      <hr />
      <.button type="button" phx-click="update_count">Inc</.button>
      <%= @count %>

      <hr />
      <.live_component module={P3} id={3} />
    </div>
    """
  end

  @impl true
  def handle_event("update_count", _unsigned_params, socket) do
    Task.start(fn ->
      Phoenix.LiveView.send_update(self(), LiveNavWeb.P3,
        id: 3,
        update_count: socket.assigns.count + 1
      )
    end)

    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def handle_event("stream", _unsigned_params, socket) do
    StreamSymbolSup.start(@symbol)
    {:noreply, socket}
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
    {:noreply, socket}
  end

  def handle_info(%{topic: "price", event: _event, payload: payload}, socket) do
    IO.puts("task_________________")

    # Task.start(fn ->
    #   send_update(P1, id: 1, price_update: payload)
    # end)

    {:noreply, assign(socket, :price_update, payload)}
  end
end
