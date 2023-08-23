defmodule LiveNavWeb.P2 do
  use LiveNavWeb, :live_component

  # use Phoenix.LiveComponent
  import LiveNavWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Page 2</h1>
      <p><%= @lc_count %></p>
      <.button type="button" phx-click="update_p2_count" phx-target={@myself}>Inc</.button>
      <p>Page 2 count: <%= @p2_count %></p>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign_new(socket, :p2_count, fn -> 0 end)}
  end

  @impl true
  def handle_event("update_p2_count", _unsigned_params, socket) do
    send(self(), {:p2_count, socket.assigns.p2_count})
    {:noreply, update(socket, :p2_count, &(&1 + 1))}
  end
end
