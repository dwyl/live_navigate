defmodule LiveNavWeb.P1 do
  use Phoenix.LiveComponent

  @impl true
  attr :sym, :integer

  def render(assigns) do
    ~H"""
    <div>
      <h1>Page 1</h1>
      <p><%= @lc_count %></p>
    </div>
    """
  end
end
