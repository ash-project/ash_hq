defmodule AshHq.Discord.Listener do
  @moduledoc """
  Does nothing for now. Eventually will support slash commands to search AshHQ from discord.
  """
  use Nostrum.Consumer

  import Bitwise

  @user_id 1_066_406_803_769_933_834
  @server_id 711_271_361_523_351_632

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def search_results!(interaction) do
    search =
      interaction.data.options
      |> Enum.find_value(fn option ->
        if option.name == "search" do
          option.value
        end
      end)

    item_list = AshHq.Docs.Indexer.search(search)

    item_list = Enum.take(item_list, 10)

    count =
      case Enum.count(item_list) do
        10 ->
          "the top 10"

        other ->
          "#{other}"
      end

    """
    Found #{count} results for "#{search}":

    #{Enum.map_join(item_list, "\n", &render_search_result(&1))}
    """
  end

  defp render_search_result(item) do
    link =
      case item do
        %AshHq.Docs.Guide{} ->
          Path.join("https://ash-hq.org", AshHqWeb.DocRoutes.doc_link(item))

        item ->
          AshHqWeb.DocRoutes.doc_link(item)
      end

    case item do
      %{name: name} ->
        "* #{name}: #{link}"

      _ ->
        "* forum message: #{link}"
    end
  end

  def handle_event({:INTERACTION_CREATE, %Nostrum.Struct.Interaction{} = interaction, _ws_state}) do
    public =
      interaction.data.options
      |> Enum.find_value(fn option ->
        if option.name == "public" do
          option.value
        end
      end)

    response = %{
      # ChannelMessageWithSource
      type: 4,
      data: %{
        content: search_results!(interaction),
        flags:
          if public do
            1 <<< 2
          else
            1 <<< 6 ||| 1 <<< 2
          end
      }
    }

    Nostrum.Api.create_interaction_response(interaction, response)
  end

  def handle_event({:READY, _msg, _ws_state}) do
    # What is happening? For some reason startup is getting timeouts at the ecto pool?
    Task.async(fn ->
      :timer.sleep(:timer.seconds(30))
      rebuild()
    end)
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end

  def rebuild do
    if Application.get_env(:ash_hq, :discord_bot) do
      build_search_action()
    end
  end

  defp build_search_action do
    command = %{
      name: "ash_hq_search",
      description: "Search AshHq Documentation",
      options: [
        %{
          # ApplicationCommandType::STRING
          type: 3,
          name: "search",
          description: "what you want to search for",
          required: true
        },
        %{
          # ApplicationCommandType::Boolean
          type: 5,
          name: "public",
          description: "If the results should be shown publicly in the channel",
          required: false
        }
      ]
    }

    Nostrum.Api.create_guild_application_command(
      @user_id,
      @server_id,
      command
    )
  end
end
