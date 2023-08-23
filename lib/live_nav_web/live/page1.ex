defmodule LiveNavWeb.P1 do
  use LiveNavWeb, :live_component
  require Logger

  @topic "price"

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Page 1</h1>
      <p><%= @lc_count %></p>
      <hr />
      <div id="chart" phx-hook="StockChart" class="h-screen flex items-center justify-center"></div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    if connected?(socket) do
      :ok = manage_subscription()
    end

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket |> assign(lc_count: assigns.lc_count)

    if assigns.price_update,
      do: {:ok, push_event(socket, "price_update", assigns.price_update)},
      else: {:ok, socket}
  end

  def manage_subscription do
    topic = Registry.keys(LiveNav.PubSub, self())

    if length(topic) > 0,
      do: :ok = Phoenix.PubSub.unsubscribe(LiveNav.PubSub, hd(topic))

    LiveNavWeb.Endpoint.subscribe(@topic)
  end
end
