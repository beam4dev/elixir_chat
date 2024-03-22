defmodule ElixirChatWeb.RoomLive do
  use ElixirChatWeb, :live_view
  require Logger

  @spec mount(map(), any(), Phoenix.LiveView.Socket.t()) :: {:ok, any()}
  def mount(%{"id" => room_id}, _session, socket) do
    user = MnemonicSlugs.generate_slug()

    # Generate Random Text "A-B"
    random_letter = fn -> [Enum.random(?A..?Z)] |> List.to_string() end
    svg_text = "#{random_letter.()}-#{random_letter.()}"

    topic = "room: #{room_id}"

    if connected?(socket) do
      ElixirChatWeb.Endpoint.subscribe(topic)

      {:ok, _} =
        ElixirChatWeb.Presence.track(self(), topic, user, %{joined_at: :os.system_time(:seconds), svg_text:  svg_text})

    end

    form = to_form(%{"message" => ""})

    socket =
      socket
      |> assign(room: room_id)
      |> assign(form: form)
      |> assign(topic: topic)
      |> assign(user: user)
      |> assign(svg_text: svg_text)
      |> assign(user_list: [])

    {:ok, stream(socket, :messages, [])}
  end

  def handle_event("submit_message", %{"message" => message}, socket) do
    meesage_submitted = "Current message #{message} "
    Logger.info(meesage_submitted)

    message = %{
      id: UUID.uuid4(),
      content: message,
      user: socket.assigns.user,
      svg_text: socket.assigns.svg_text
    }

    ElixirChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)
    {:noreply, socket}
  end

  def handle_info(%{event: "new-message", payload: payload, topic: _topic}, socket) do
    {:noreply,
     socket
     |> stream_insert(:messages, payload)}
  end

  def handle_info(%{event: "presence_diff", payload: %{leaves: leaves, joins: joins}}, socket) do
    join_messages = create_messages(joins, "joined", socket.assigns.svg_text)
    leaves_messages = create_messages(leaves, "left", socket.assigns.svg_text)

    user_list = ElixirChatWeb.Presence.list(socket.assigns.topic)
    user_list = Enum.map(user_list, &create_user_list/1)

    leaves_list = Map.keys(leaves)
    user_list = Enum.reject(user_list, &(&1.user in leaves_list))

    socket = assign(socket, :user_list, user_list)

    {:noreply, stream(socket, :messages, join_messages ++ leaves_messages)}
  end

  defp create_messages(data, content, svg_text) do
    data
    |> Map.keys()
    |> Enum.map(fn user ->
      %{
        id: UUID.uuid4(),
        content: "#{user} #{content}",
        user: "System",
        svg_text: svg_text
      }
    end)
  end

  defp create_user_list({user, %{metas: metas}}), do: %{user: user, svg_text: hd(metas).svg_text}

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  attr(:text, :any, required: true)
  def svg_img(assigns) do
    IO.inspect(svg_img: assigns)

    ~H"""
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
      <circle cx="75" cy="61" r="25" fill={svg_color()} />
      <text x="75" y="61" dominant-baseline="middle" text-anchor="middle" font-size="20" fill="white">
        <%=@text%></text>
    </svg>
    """
  end

  defp svg_color() do
    random_color = fn -> Enum.random(0..255) end
    color = "rgb(#{random_color.()}, #{random_color.()}, #{random_color.()})"
    color
  end
end
