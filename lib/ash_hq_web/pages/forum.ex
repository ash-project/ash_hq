defmodule AshHqWeb.Pages.Forum do
  @moduledoc "Forum page"
  use Surface.LiveComponent

  require Ash.Query

  alias AshHqWeb.Components.Blog.Tag
  alias AshHqWeb.Components.Forum.Attachment
  alias Surface.Components.LivePatch

  import AshHqWeb.Tails

  prop(params, :map, default: %{})

  data(thread, :any, default: nil)
  data(threads, :any, default: [])
  data(tag, :string, default: nil)
  data(tags, :any, default: [])
  data(channels, :any, default: [])
  data(channel, :any, default: [])

  def render(assigns) do
    ~F"""
    <div class="container md:mx-auto">
      <div class="flex flex-col md:flex-row md:pt-32 md:mx-32 min-h-screen">
        <div class="w-full">
          {#if @thread}
            <div class="flex flex-row space-x-4 mb-6">
              <LivePatch
                class={classes([
                  "px-4 py-2 rounded-xl text-center border-2 bg-primary-light-300 dark:bg-primary-dark-200 border-primary-light-300 dark:text-black dark:border-primary-dark-200"
                ])}
                to={"/forum/#{@channel.name}"}
              >
                <div class="flex flex-row">
                  <Heroicons.Outline.ArrowLeftIcon class="h-6 w-6 mr-2" />
                  Back to {String.capitalize(@channel.name)}
                </div>
              </LivePatch>
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
                  {@thread.author}
                </div>
                <div>
                  {@thread.create_timestamp |> DateTime.to_date()}
                </div>

                <div class="flex space-x-2">
                  {#for tag <- @thread.tags}
                    <Tag prefix={"/forum/#{@channel.name}"} tag={tag.name} />
                  {/for}
                </div>
              </div>
              <div class="divide-y divide-solid space-y-6 mt-4">
                {#for message <- @thread.messages}
                  <div class="prose dark:prose-invert break-words">
                    <p>
                      {message.author}:
                    </p>{raw(message.content_html)}
                    {#for attachment <- message.attachments}
                      <Attachment attachment={attachment} />
                    {/for}
                  </div>
                {/for}
              </div>
            </div>
          {#else}
            <h2 class="text-xl font-bold mt-2">
              Channels
            </h2>
            <div class="flex flex-row space-x-4 mb-6">
              {#for channel <- @channels}
                <LivePatch
                  class={classes([
                    "px-4 py-2 rounded-xl text-center border-2 border-black dark:border-white",
                    "bg-primary-light-600 dark:bg-primary-dark-500 border-primary-light-600 dark:text-black dark:border-primary-dark-500":
                      @channel && @channel.id == channel.id
                  ])}
                  to={"/forum/#{channel.name}"}
                >
                  {String.capitalize(channel.name)}
                </LivePatch>
              {/for}
            </div>
            <div class="flex flex-row space-x-6 w-full justify-start ml-2 md:ml-0">
              {#if @threads.offset != 0}
                <LivePatch to={"/forum/#{@channel.name}?offset=#{min(@threads.offset - @threads.limit, 0)}"}>
                  <div class="px-4 py-2 rounded-xl text-center border-2 bg-primary-light-500 dark:bg-primary-dark-400 border-primary-light-500 dark:text-black dark:border-primary-dark-400">
                    Previous Page
                  </div>
                </LivePatch>
              {/if}

              {#if @threads.more?}
                <LivePatch to={"/forum/#{@channel.name}?offset=#{@threads.offset + @threads.limit}"}>
                  <div class="px-4 py-2 rounded-xl text-center border-2 bg-primary-light-500 dark:bg-primary-dark-400 border-primary-light-500 dark:text-black dark:border-primary-dark-400">
                    Next Page
                  </div>
                </LivePatch>
              {/if}
            </div>
            <head>
              <meta property="og:title" content="Ash Framework Forum">
              <meta
                property="og:description"
                content="A declarative foundation for ambitious Elixir applications. Model your domain, derive the rest."
              />
            </head>
            {#if @tag}
              <h2 class="text-2xl font-semibold mb-1 mt-2">Showing {page_info(@threads)} with tag: {@tag}</h2>
            {#else}
              <h2 class="text-2xl font-semibold mb-1 mt-2">Showing {page_info(@threads)}</h2>
            {/if}
            <div>
              {#for thread <- @threads.results}
                <div class="border shadow-sm rounded-lg px-8 pb-6 dark:border-gray-600 mb-4" ">
                  <h2 class="mt-6 text-3xl font-semibold mb-4">{thread.name}</h2>
                  <div class="border-b pb-2">
                    <div>
                      {thread.author}
                    </div>
                    <div>
                      {thread.create_timestamp |> DateTime.to_date()}
                    </div>

                    <div class="flex flex-col md:flex-row items-center mt-2 py-2 space-x-2">
                      <LivePatch
                        to={"/forum/#{@channel.name}/#{thread.id}"}
                        class="bg-primary-light-600 dark:bg-primary-dark-500 dark:text-black align-middle px-4 py-2 rounded-lg"
                      >
                        <div class="flex flex-row items-center">
                          <span>Read</span><Heroicons.Solid.ArrowRightIcon class="h-4 w-4" />
                        </div>
                      </LivePatch>
                      <a
                        _target="blank"
                        href={"discord://discordapp.com/channels/#{711_271_361_523_351_632}/#{thread.id}"}
                        class="bg-primary-light-300 dark:bg-primary-dark-300 dark:text-black align-middle px-4 py-2 rounded-lg mt-2 md:mt-0"
                      >
                        <div class="flex flex-row items-center">
                          <span class="whitespace-nowrap">Discord App</span>
                        </div>
                      </a>
                      <a
                        _target="blank"
                        href={"https://discord.com/channels/#{711_271_361_523_351_632}/#{thread.id}"}
                        class="bg-primary-light-300 dark:bg-primary-dark-300 dark:text-black align-middle px-4 py-2 rounded-lg mt-2 md:mt-0"
                      >
                        <div class="flex flex-row items-center">
                          <span class="whitespace-nowrap">Discord Web</span>
                        </div>
                      </a>
                    </div>
                    <div class="flex space-x-2">
                      {#for tag <- thread.tags}
                        <Tag prefix={"/forum/#{@channel.name}"} tag={tag.name} />
                      {/for}
                    </div>
                  </div>
                </div>
              {/for}
            </div>
            <div class="flex flex-row space-x-6 w-full justify-start ml-2 md:ml-0">
              {#if @threads.offset != 0}
                <LivePatch to={"/forum/#{@channel.name}?offset=#{@threads.offset - @threads.limit}"}>
                  <div class="px-4 py-2 rounded-xl text-center border-2 bg-primary-light-500 dark:bg-primary-dark-400 border-primary-light-500 dark:text-black dark:border-primary-dark-400">
                    Previous Page
                  </div>
                </LivePatch>
              {/if}

              {#if @threads.more?}
                <LivePatch to={"/forum/#{@channel.name}?offset=#{@threads.offset + @threads.limit}"}>
                  <div class="px-4 py-2 rounded-xl text-center border-2 bg-primary-light-500 dark:bg-primary-dark-400 border-primary-light-500 dark:text-black dark:border-primary-dark-400">
                    Next Page
                  </div>
                </LivePatch>
              {/if}
            </div>
          {/if}
        </div>
        {#if !@thread}
          <div class={classes(["flex flex-col px-4 md:pr-0 md:pl-4 md:w-3/12 space-y-6", "mt-9": !@thread])}>
            <div class="border rounded-lg p-4 flex flex-col w-full dark:border-gray-600">
              <h3 class="text-lg font-bold mb-1">All Tags:</h3>
              <div class="flex gap-2 flex-wrap w-full">
                {#for tag <- @tags}
                  <Tag prefix={"/forum/#{@channel.name}"} tag={tag} />
                {/for}
              </div>
            </div>
          </div>
        {/if}
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
      assign(socket, :thread, nil)
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
        &(&1.name == channel_name)
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

  defp page_info(%{results: []}) do
    "no threads "
  end

  defp page_info(%{more?: false, offset: 0, count: count}) do
    "all #{count} threads "
  end

  defp page_info(%{more?: false, results: results, count: count}) do
    "the last #{Enum.count(results)} of #{count} threads "
  end

  defp page_info(%{offset: 0, limit: limit, count: count}) do
    "the first #{limit} of #{count} threads "
  end

  defp page_info(%{offset: offset, limit: limit, count: count}) do
    "threads #{offset + 1} to #{offset + limit} of #{count}"
  end
end
