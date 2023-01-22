defmodule AshHq.Discord.Poller do
  @moduledoc """
  Every 2 hours, synchronizes all active threads and the 50 most recent archived threads
  """

  use GenServer

  @poll_interval :timer.hours(1)
  @server_id 711_271_361_523_351_632
  @archived_thread_lookback 50

  @channels [
    1_066_222_835_758_014_606,
    1_066_223_107_922_210_867,
    1_019_647_368_196_534_283
  ]

  def server_id, do: @server_id

  defmacrop unwrap(value) do
    quote do
      case unquote(value) do
        {:ok, value} ->
          value

        {:error, error} ->
          raise Exception.format(:error, error, [])
      end
    end
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    Process.send_after(self(), :poll, @poll_interval)
    {:ok, nil}
  end

  def handle_info(:poll, state) do
    poll()
    Process.send_after(self(), :poll, @poll_interval)
    {:noreply, state}
  end

  def poll do
    for {channel, index} <- Enum.with_index(@channels) do
      channel
      |> Nostrum.Api.get_channel!()
      |> tap(fn channel ->
        channel
        |> Map.from_struct()
        |> Map.put(:order, index)
        |> AshHq.Discord.Channel.upsert!()
      end)
      |> Map.get(:available_tags)
      |> Enum.each(fn available_tag ->
        AshHq.Discord.Tag.upsert!(channel, available_tag.id, available_tag.name)
      end)
    end

    active =
      @server_id
      |> Nostrum.Api.list_guild_threads()
      |> unwrap()
      |> Map.get(:threads)
      |> Stream.filter(fn thread ->
        thread.parent_id in @channels
      end)
      |> Stream.map(fn thread ->
        %{
          thread: thread,
          messages: get_all_channel_messages(thread.id)
        }
      end)

    archived =
      @channels
      |> Stream.flat_map(fn channel ->
        channel
        |> Nostrum.Api.list_public_archived_threads(limit: @archived_thread_lookback)
        |> unwrap()
        |> Map.get(:threads)
        |> Enum.map(fn thread ->
          messages =
            thread.id
            |> get_all_channel_messages()

          %{
            thread: thread,
            messages: messages
          }
        end)
      end)

    active
    |> Stream.concat(archived)
    |> Enum.reject(fn
      %{messages: []} ->
        true

      _ ->
        false
    end)
    |> Enum.each(fn %{thread: thread, messages: messages} ->
      thread
      |> Map.put(:author, Enum.at(messages, 0).author)
      |> Map.from_struct()
      |> Map.put(:channel_id, thread.parent_id)
      |> Map.put(:tags, thread.applied_tags)
      |> Map.put(:create_timestamp, thread.thread_metadata.create_timestamp)
      |> Map.put(:messages, Enum.map(messages, &Map.from_struct/1))
      |> AshHq.Discord.Thread.upsert!()
    end)
  end

  defp get_all_channel_messages(thread) do
    Stream.resource(
      fn ->
        :all
      end,
      fn
        nil ->
          {:halt, nil}

        before ->
          locator =
            case before do
              :all ->
                nil

              before ->
                {:before, before}
            end

          messages =
            if locator do
              Nostrum.Api.get_channel_messages!(thread, 100, locator)
            else
              Nostrum.Api.get_channel_messages!(thread, 100)
            end

          if Enum.count(messages) == 100 do
            {messages, List.last(messages).id}
          else
            {messages, nil}
          end
      end,
      & &1
    )
    |> Stream.map(fn message ->
      message
      |> Map.put(:author, message.author.username)
      |> Map.update!(:reactions, fn reactions ->
        reactions
        |> Kernel.||([])
        # just don't know what this looks like, so removing them
        |> Enum.reject(&(is_nil(&1.emoji) || &1.emoji == "" || &1.emoji.animated))
        |> Enum.map(fn %{count: count, emoji: emoji} ->
          %{emoji: emoji.name, count: count}
        end)
      end)
      |> Map.update!(:attachments, fn attachments ->
        Enum.map(attachments, &Map.from_struct/1)
      end)
    end)
    |> Enum.to_list()
  end
end
