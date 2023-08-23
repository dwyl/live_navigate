# LiveNav

```bash
 mix phx.new live_nav --no-ecto --no-dashboard --no-gettext --no-mailer
```

‼️ Draft mode - please raise issues

## Objectives

1. Navigate between LiveComponents
2. Active tab

<img width="874" alt="Screenshot 2023-08-23 at 09 43 44" src="https://github.com/dwyl/live_navigate/assets/6793008/445519d2-2677-4b7d-baaf-8d91d4b1c6dd">

## Navigation

We put a navigation `nav` tag in the "/components/layouts/app.html.heex" file. It will render some static HTML. We implement the navbar with a traditional "ul/li".

```elixir
#layouts/app.html.heex
<nav class="flex justify-between items-center font-bold text-[bisque] bg-[midnightblue]">
  <h3 class="px-2">NavBar: Livecomponents</h3>
  <ul class="list-none flex">
    <%= for {label, page, uri} <- @menu do %>
      <li class="rounded-md px-2 py-2">
        <.link patch={page} class={["", uri == @current_path && @active]}>
          <%= label %>
        </.link>
      </li>
    <% end %>
  </ul>
</nav>
```

We used the attributes `current_path`, `active` and `menu`. They are set up in the `mount` function.

The `active` attribute is a Tailwind class to hightlight the nav element when it is active: we just invert the colours of the text and background.

The `menu` assign is a list of tuples containing the label, path and selector per LiveComponent:

```elixir
assign(socket,
  menu: [
      {"Home", path(socket, LiveNavWeb.Router, ~p"/"), ""},
      {"Page 1", "/?page=p1", "p1"},
      {"Page 2", "/?page=p2", "p2"}
      ],
  active: "text-[midnightblue] bg-[bisque] px-1 py-1"
)
```

We mount a LiveView say at the uri "/", declared in the router module via `live "/", HomeLive`.

One way to render LiveComponents by navigation within a LiveView is to `<.link patch />`, cf [here](https://hexdocs.pm/phoenix_live_view/live-navigation.html).

We set the `patch` attribute value as a query string `patch={"/?page=1"}`. When we click on this link, the query string will be captured in a `handle_params(%{"page" => page}, _uri, socket)` callback of the LV.

In this callback, we update the `current_path` assign of the LV. By changing an assign of the LV, we trigger a render.

In the LiveView, we have several `render/1`, namely one specific per LiveComponent. For example, when we click on "page 1", we assign `current_path: "p1"` and reach `render(%{current_path: p1})`. The LiveView will render this specific LiveComponent.

## LiveComponent

We set up a LiveView (LV) and LiveComponents (LC) as children to this LV. Each LC has its own state. They are [render with](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html) `live_component`:

```elixir
# home_live.ex
def render(%{current_path: "p2"}) do
  ~H"""
    <.live_component module={P2} id={2}/>
  """
end
```

The static HTML is simply:

```elixir
#P2.ex
def render(assigns) do
  ~H"""
    <div>
      <h1>Page 2 </h1>
    </div>
  """
end
```

> Note that a LC must have a single static HTML tag at the root (think of `React`)

## Active page

An example of how to do this using a `live_session` and `on_mount` is explained [here](https://fly.io/phoenix-files/liveview-active-nav/). This code is extracted from the LiveBeats demo app.

We will do something more simple. To highlight the active page, we need to access to the `current_path`. It is accessible in the `handle_params` callback.Since we put the page reference in the query string, we can capture it in the "params" argument - the first one - of the `handle_params` callback. We update the `current_path` attribute of the LiveView with this value.

The assign `current_path` will match or not the "uri" each time we navigate.

## Pass data from the LiveView to the LiveComponents

Suppose we want to increment a counter in the LiveView. We have a button with a `phx-click` attribute that triggers a `handle_event` callback where we change the attribute say `count`.

We can pass data from the LV to the LC via **attributes**. Since a LC is rendered from the LV, we can pass the LV attribute `count` to the LC

```elixir
#HomeLive.ex
def render(%{current_path: "p2"}) do
  ~H"""
    <.live_component module={P2} id={2} lc_count={@count}/>                                            ^^^
  """
end
```

and the static HTML of a LiveComponent will have an assign `assigns.lc_count` available to render:

```elixir
#P2.ex
def render(assigns) do
  ~H"""
    <div>
      <h1>Page 1</h1>
      <%= @lc_count %>
    </div>
  """
end
```

When you click on the button in the LV and navigate to say page 1, it will display the current value of the counter.

<img width="1126" alt="Screenshot 2023-08-23 at 12 13 54" src="https://github.com/dwyl/live_navigate/assets/6793008/8d6a4eb8-e56a-40a5-aeba-8cf58f0e5282">

## Pass data from a LiveComponent to the parent LiveView

Since the LV and LC are in the same process, we will use a simple `Kernel.send`.

To illustrate this, we will implement a counter in "page 2". In the `mount/1` of "P2" LiveComponent, we add an assign

```elixir
#P2.ex
def mount(socket) do
  {:ok, assign_new(socket, :p2_count, fn -> 0 end)}
end
```

We `import LiveNavWeb.CoreComponents` to have access to the built-in "core components". The HTML is updated to

```elixir
#P2.ex
import LiveNavWeb.CoreComponents

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
```

We used the attribute `phx-target={@myself}`: when we click on the button, this will send an event to the LC, and not to the parent LV.

When handle this event, we `Kernel.send` to `self()` (the core process, the LiveView):

```elixir
#P2.ex
def handle_event("update_p2_count", _unsigned_params, socket) do
  send(self(), {:p2_count, socket.assigns.p2_count})
  {:noreply, update(socket, :p2_count, &(&1 + 1))}
end
```

It remains to `handle_info` in the LV:

```elixir
def handle_info({:p2_count, v}, socket) do
  IO.inspect(v)
  {:noreply, socket}
end
```

## Embed a LC in the LV

We can of course display a LC in the LV. Update the HTML:

```elixir
def render(assigns) do
  ~H"""
  <div>
    <h1>Home page</h1>
    <.button type="button" phx-click="update_count">Inc</.button>
    <%= @count %>

    <hr />
    <.live_component module={P3} id={3} lc_count={@count} />
  </div>
  """
end
```

and define a new LC "P3". When you click on the button, the count is incremented in the LC as well.

<img width="242" alt="Screenshot 2023-08-23 at 12 11 04" src="https://github.com/dwyl/live_navigate/assets/6793008/39aa6d50-9ceb-4500-8ef2-508c83e11a92">

## Send data from the LV to an embedded LC

We saw we can use an attribute in the `live_component` to pass data from the LV to the LC.

We can also use `Phoenix.LiveView.send_update` (<https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#send_update/3>).

Remove the "lc_count" assign for "P3".

```elixir
def render(assigns) do
  ~H"""
  <div>
    <h1>Home page</h1>
    <.button type="button" phx-click="update_count">Inc</.button>
    <%= @count %>

    <hr />
    <.live_component module={P3} id={3} />
  </div>
  """
end
```

Then redefine "P3" and add an internal assign `update_count` (via the `mount/1` of the LC):

```elixir
#P3.ex
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
```

We don't pass anymore the updated `count` attribute from the LV when we click the button, but instead
we `send_update` as:

```elixir
#HomeLive.ex
def handle_event("update_count", _unsigned_params, socket) do
  Phoenix.LiveView.send_update(self(), LiveNavWeb.P3,
    id: 3,
    update_count: socket.assigns.count + 1
  )

  {:noreply, update(socket, :count, &(&1 + 1))}
end
```

Now, each time we click on the counter in the LV, we send an update to the embeded LC to increment its internal state.

<img width="298" alt="Screenshot 2023-08-23 at 12 06 28" src="https://github.com/dwyl/live_navigate/assets/6793008/088e1b30-22b6-480f-a691-dfdeb051574c">

Note that we cannot `send_update` to an "un-mounted" LiveComponenent. This works because "P3" is already mounted. This means that if we want to send messages between LiveComponents, we have to send a message to the parent Liveview, save it in the LV state, and the LV will pass it to the the targeted LC once mounted.

## Stream to LiveComponent

We illustrate a streaming of data to a child LiveComponent in the branch "stream". We use `Websockex` for this and broadcast to hte LiveView. This process is dynamically supervised (since it would be stopped when we unmount the LV). We subscribe to the topic when we mount the LC (care is taken not to subscribe several times). When the LV receives an event, we update the assigns in the LV, and the callback `update/2` in the LC receives them. To illustrate this, we bring in a chart - via a hook - that is updated via a `push_event` (and the alter-ego `handleEvent`).
