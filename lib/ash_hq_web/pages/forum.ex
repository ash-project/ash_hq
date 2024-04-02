defmodule AshHqWeb.Pages.Forum do
  @moduledoc "Forum page"
  use Phoenix.LiveComponent

  require Ash.Query

  alias AshHqWeb.Components.Blog.Tag
  alias AshHqWeb.Components.Forum.Attachment

  attr(:params, :map, default: %{})

  def render(assigns) do
    ~H"""
    <div class="container md:mx-auto">
      <div class="flex flex-col md:flex-row md:pt-32 md:mx-32 min-h-screen">
        <div class="w-full">
            <div class="flex flex-row space-x-4 mb-6">
              <a
                _target="blank"
                href={"discord://discordapp.com/channels/#{711_271_361_523_351_632}/#{@thread.id}"}
                class="bg-primary-light-300 dark:bg-primary-dark-300 dark:text-black align-middle px-4 py-2 rounded-lg mt-2 md:mt-0"
              >
                <div class="flex flex-row items-center">
                  <span class="whitespace-nowrap">Discord App</span>
                </div>
              </a>
              <a
                _target="blank"
                href={"https://discord.com/channels/#{711_271_361_523_351_632}/#{@thread.id}"}
                class="bg-primary-light-300 dark:bg-primary-dark-300 dark:text-black align-middle px-4 py-2 rounded-lg mt-2 md:mt-0"
              >
                <div class="flex flex-row items-center">
                  <span class="whitespace-nowrap">Discord Web</span>
                </div>
              </a>
            </div>
            <head>
              <meta property="og:title" content={@thread.name}>
              <meta
                property="og:description"
                content={"See the forum discussion in the #{String.capitalize(@channel.name)} channel"}
              />
            </head>
            <div class="border shadow-sm rounded-lg px-8 pb-6 dark:border-gray-600 mb-4">
              <h2 class="mt-6 text-3xl font-semibold mb-4">{@thread.name}</h2>
              <div class="border-b pb-2">
                <div>
                  <%= @thread.author %>
                </div>
                <div>
                  <%= @thread.create_timestamp |> DateTime.to_date() %>
                </div>

                <div class="flex space-x-2">
                  <%= for tag <- @thread.tags do %>
                    <Tag.tag prefix={"/forum/#{@channel.name}"} tag={tag.name} />
                  <% end %>
                </div>
              </div>
              <div class="divide-y divide-solid space-y-6 mt-4">
                <%= for message <- @thread.messages do %>
                  <div class="prose dark:prose-invert break-words">
                    <p>
                      <%= message.author %>:
                    </p><%= Phoenix.HTML.raw(message.content_html) %>
                    <%= for attachment <- message.attachments do %>
                      <Attachment.attachment attachment={attachment} />
                    <% end %>
                  </div>
                <% end %>
              </div>
            </div>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_channels()
      |> assign_channel()
      |> assign_tags()
      |> assign_tag()
      |> assign_thread()
      |> assign_threads()
    }
  end

  defp assign_tags(socket) do
    tags =
      AshHq.Discord.Tag
      |> Ash.Query.distinct(:name)
      |> Ash.Query.filter(channel_id == ^socket.assigns.channel.id)
      |> Ash.Query.select(:name)
      |> Ash.Query.sort(:name)
      |> AshHq.Discord.read!()
      |> Enum.map(&to_string(&1.name))

    assign(socket, :tags, tags)
  end

  defp assign_tag(socket) do
    tag =
      if socket.assigns.params["tag"] do
        Enum.find(
          socket.assigns.tags,
          &Ash.Type.CiString.equal?(&1, socket.assigns.params["tag"])
        )
      end

    assign(socket, :tag, tag)
  end

  defp assign_thread(socket) do
    if socket.assigns.params["id"] do
      messages_query =
        AshHq.Discord.Message
        |> Ash.Query.sort(timestamp: :asc)
        |> Ash.Query.deselect(:content)
        |> Ash.Query.load(:attachments)

      assign(
        socket,
        :thread,
        AshHq.Discord.Thread.by_id!(socket.assigns.params["id"],
          load: [:tags, messages: messages_query]
        )
      )
    else
      socket
      |> push_redirect(to: "/")
    end
  end

  defp assign_threads(socket) do
    assign(
      socket,
      :threads,
      AshHq.Discord.Thread.feed!(
        socket.assigns.channel.id,
        %{tag_name: socket.assigns.tag},
        page: [offset: String.to_integer(socket.assigns.params["offset"] || "0"), count: true],
        load: :tags
      )
    )
  end

  defp assign_channels(socket) do
    assign(socket, :channels, AshHq.Discord.Channel.read!() |> Enum.sort_by(& &1.order))
  end

  defp assign_channel(socket) do
    channel_name = socket.assigns.params["channel"] || "showcase"

    channel =
      Enum.find(
        socket.assigns.channels,
        &(String.trim_trailing(&1.name, "-archive") == channel_name)
      )

    if is_nil(channel) do
      raise Ash.Error.Query.NotFound.exception(primary_key: %{name: channel_name})
    end

    assign(
      socket,
      :channel,
      channel
    )
  end
end
