defmodule AshHq.Discord.Listener do
  @moduledoc """
  Does nothing for now. Eventually will support slash commands to search AshHQ from discord.
  """
  use Nostrum.Consumer

  import Bitwise
  @all_types AshHq.Docs.Extensions.Search.Types.types() -- ["Forum"]

  @user_id 1_066_406_803_769_933_834

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

    type =
      interaction.data.options
      |> Enum.find_value(fn option ->
        if option.name == "type" do
          option.value
        end
      end)

    library =
      interaction.data.options
      |> Enum.find_value(fn option ->
        if option.name == "library" do
          option.value
        end
      end)

    libraries =
      AshHq.Docs.Library.read!()
      |> Enum.filter(& &1.latest_version_id)

    library_version_ids =
      if library do
        case Enum.find(libraries, &(&1.name == library)) do
          nil ->
            []

          library ->
            [library.latest_version_id]
        end
      else
        Enum.map(libraries, & &1.latest_version_id)
      end

    input =
      if type do
        %{types: [type]}
      else
        %{types: @all_types}
      end

    %{result: item_list} = AshHq.Docs.Search.run!(search, library_version_ids, input)

    result_type =
      if type do
        "#{type} results"
      else
        "results"
      end

    library =
      if library do
        "#{library}"
      else
        "all libraries"
      end

    if item_list do
      item_list = Enum.take(item_list, 10)

      count =
        case Enum.count(item_list) do
          10 ->
            "the top 10"

          other ->
            "#{other}"
        end

      """
      Found #{count} #{result_type} in #{library} for query "#{search}":

      #{Enum.map_join(item_list, "\n", &render_search_result(&1))}
      """
    else
      "Something went wrong."
    end
  end

  defp render_search_result(item) do
    link = Path.join("https://ash-hq.org", AshHqWeb.DocRoutes.doc_link(item))

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
      libraries =
        AshHq.Docs.Library.read!()
        |> Enum.filter(& &1.latest_library_version)

      build_search_action(libraries)
    end
  end

  defp build_search_action(libraries) do
    library_names =
      libraries
      |> Enum.map(& &1.name)

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
          # ApplicationCommandType::STRING
          type: 3,
          name: "type",
          description: "What type of thing you want to search for. Defaults to everything.",
          required: false,
          choices:
            Enum.map(@all_types, fn type ->
              %{
                name: String.downcase(type),
                description: "Search only for #{String.downcase(type)} items.",
                value: type
              }
            end)
        },
        %{
          # ApplicationCommandType::STRING
          type: 3,
          name: "library",
          description: "Which library you'd like to search. Defaults to all libraries.",
          required: false,
          choices:
            Enum.map(library_names, fn name ->
              %{
                name: name,
                description: "Search only in the #{name} library.",
                value: name
              }
            end)
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
      AshHq.Discord.Poller.server_id(),
      command
    )
  end
end
