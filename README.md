# LiveNav

```bash
 mix phx.new live_nav --no-ecto --no-dashboard --no-gettext --no-mailer
```

## Objectives

1. Navigate between LiveComponents
2. Active tab

## Navigation

We put a navigation `nav` tag in the "/components/layouts/app.html.heex" file. It will render some static HTML (see the Active Page below).

We implement the navbar with a traditional "ul/li".

```html
<ul>
    <%= for {label, page, uri} <- @menu do %>
      <li>
        <.link patch={page} class={["", uri == @current_path && @active]}>
          <%= label %>
        </.link>
      </li>
    <% end %>
  </ul>
```

We used the attributes `current_path`, `active` and `menu`. They will be assigned in the `mount` function.

The `active`is a Tailwind class to hightlight the nav element when it is active.

The `menu` assign is a list of tuples containing the label, path and selector per LiveComponent:

```elixir
menu: [
    {"Home", path(socket, LiveNavWeb.Router, ~p"/"), ""},
    {"Page 1", "/?page=p1", "p1"},
    {"Page 2", "/?page=p2", "p2"}
    ],
active: "some classes"
```

We mount a LiveView say at the uri "/", declared in the router via `live "/", HomeLive`.

One way to render LiveComponents by navigation within a LiveView is to `<.link patch />`, cf [here](https://hexdocs.pm/phoenix_live_view/live-navigation.html).

We use the query string `patch={"/?page=1"}`. When we click on this link, the query string will be captured in a `handle_params`callback of the LV.

In this callback, we update the `current_path` assign of the LV. By changing an assign of the LV, we trigger a render.

In the LiveView, we have specific `render/1` functions per LiveComponent. For example `render(%{current_path: 1})`. The LiveView will render this specific LiveComponent.

## LiveComponent

We set up a LiveView (LV) and LiveComponents (LC) as children to this LV. Each LC has its own state.

```elixir
~H"""
  <.live_component module={P2} id={2}/>
"""
```

Tthe static HTML is simply:

```elixir
~H"""
  <div>
    <h1>Page 1</h1>
  </div>
"""
```

> Note that a LC must have a single static HTML tag at the root (think of `React`)

## Active page

An example of how to do this using a `live_session` and `on_mount` is explained [here](https://fly.io/phoenix-files/liveview-active-nav/). This code is extracted from the LiveBeats demo app.

We will do something more simple. To highlight the active page, we need to access to the `current_path`. It is accessible in the `handle_params` callback.Since we put the page reference in the query string, we can capture it in the "params" argument - the first one - of the `handle_params` callback. We update the `current_path` attribute of the LiveView with this value.

The assign `current_path` will match or not the "uri" each time we navigate.

## Pass data from the LiveView to the LiveComponents

Suppose we want to increment a counter in the LiveView. We have a button with a `phx-click` attribute that triggers a `handle_event` callback where we change the attribute say `count`.

We can pass data from the LV to the LC via **attributes**. A LC is rendered from the LV. Note that we pass an attribute `count` from the LV to the LC

```elixir
~H"""
  <.live_component module={P2} id={2} lc_count={@count}/>
"""
```

and modify the static HTML of a LiveComponent

```elixir
~H"""
  <div>
    <h1>Page 1</h1>
    <%= @lc_count %>
  </div>
"""
```
