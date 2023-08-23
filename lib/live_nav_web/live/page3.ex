defmodule LiveNavWeb.P3 do
  use LiveNavWeb, :live_component

  # use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1>Page 3</h1>

      <p><%= @update_count %></p>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :update_count, 0)}
  end
end
