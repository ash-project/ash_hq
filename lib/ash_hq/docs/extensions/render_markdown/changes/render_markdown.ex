defmodule AshHq.Docs.Extensions.RenderMarkdown.Changes.RenderMarkdown do
  @moduledoc """
  Writes a markdown text attribute to its corresponding html attribute.
  """

  require Logger
  require Ash.Query
  use Ash.Resource.Change
  use AshHqWeb, :verified_routes

  def change(changeset, opts, _) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      if Ash.Changeset.changing_attribute?(changeset, opts[:source]) do
        source = Ash.Changeset.get_attribute(changeset, opts[:source])
        libraries = AshHq.Docs.Library.read!()
        text = process_text(source)

        attribute = Ash.Resource.Info.attribute(changeset.resource, opts[:destination])

        changeset =
          if text != source do
            Ash.Changeset.force_change_attribute(changeset, opts[:source], text)
          else
            changeset
          end

        current_module =
          cond do
            changeset.resource == AshHq.Docs.Module ->
              Ash.Changeset.get_attribute(changeset, :name)

            changeset.resource == AshHq.Docs.Function ->
              AshHq.Docs.get!(
                AshHq.Docs.Module,
                Ash.Changeset.get_attribute(changeset, :module_id)
              ).name

            true ->
              nil
          end

        current_library =
          case Ash.Changeset.get_argument(changeset, :library_version) ||
                 Ash.Changeset.get_attribute(changeset, :library_version_id) do
            nil ->
              nil

            library_version_id ->
              AshHq.Docs.Library
              |> Ash.Query.select(:name)
              |> Ash.Query.filter(versions.id == ^library_version_id)
              |> AshHq.Docs.read_one!()
              |> Map.get(:name)
          end

        case AshHq.Docs.Extensions.RenderMarkdown.as_html(
               text,
               libraries,
               current_library,
               current_module,
               AshHq.Docs.Extensions.RenderMarkdown.header_ids?(changeset.resource),
               AshHq.Docs.Extensions.RenderMarkdown.table_of_contents?(changeset.resource)
             ) do
          {:error, html_doc, error_messages} ->
            Logger.warn("""
            Error while transforming to HTML: #{inspect(error_messages)}

            Transforming:

            #{inspect(text)}

            Result:

            #{inspect(html_doc)}
            """)

            html_doc =
              case attribute.type do
                {:array, _} ->
                  List.wrap(html_doc)

                _ ->
                  html_doc
              end

            Ash.Changeset.force_change_attribute(changeset, opts[:destination], html_doc)

          {:ok, html_doc, _} ->
            html_doc =
              case attribute.type do
                {:array, _} ->
                  List.wrap(html_doc)

                _ ->
                  html_doc
              end

            Ash.Changeset.force_change_attribute(changeset, opts[:destination], html_doc)
        end
      else
        changeset
      end
    end)
  end

  @doc false
  def process_text(text) when is_list(text) do
    Enum.map(text, &process_text(&1))
  end

  def process_text(text) do
    text
    |> remove_ash_hq_hidden_content()
  end

  defp remove_ash_hq_hidden_content(nil), do: nil

  defp remove_ash_hq_hidden_content(string) do
    string
    |> String.split(~r/\<\!---.*ash-hq-hide-start.*--\>/)
    |> case do
      [string] ->
        string

      strings ->
        Enum.map_join(strings, "", fn string ->
          string
          |> String.split(~r/\<\!---.*ash-hq-hide-stop.*--\>/)
          |> case do
            [string] ->
              string

            [_ | rest] ->
              Enum.join(rest)
          end
        end)
    end
    |> String.trim()
  end
end
