defmodule AshHq.Docs.Extensions.RenderMarkdown.Changes.RenderMarkdown do
  use Ash.Resource.Change

  def change(changeset, opts, _) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      if Ash.Changeset.changing_attribute?(changeset, opts[:source]) do
        source = Ash.Changeset.get_attribute(changeset, opts[:source])
        text = remove_ash_hq_hidden_content(source)

        changeset =
          if text != source do
            Ash.Changeset.force_change_attribute(changeset, opts[:source], text)
          else
            changeset
          end

        case AshHq.Docs.Extensions.RenderMarkdown.as_html(
               text,
               AshHq.Docs.Extensions.RenderMarkdown.header_ids?(changeset.resource)
             ) do
          {:error, _, error_messages} ->
            Ash.Changeset.add_error(
              changeset,
              Ash.Error.Changes.InvalidAttribute.exception(
                field: :source,
                message: "Could not be transformed into html: #{inspect(error_messages)}"
              )
            )

          {:ok, html_doc, _} ->
            html_doc = AshHq.Docs.Extensions.RenderMarkdown.Highlighter.highlight(html_doc)

            Ash.Changeset.force_change_attribute(changeset, opts[:destination], html_doc)
        end
      else
        changeset
      end
    end)
  end

  defp remove_ash_hq_hidden_content(nil), do: nil

  defp remove_ash_hq_hidden_content(string) do
    string
    |> String.split("<!--- ash-hq-hide-start -->")
    |> case do
      [string] ->
        string

      strings ->
        Enum.map_join(strings, "", fn string ->
          string
          |> String.split("<!--- ash-hq-hide-stop -->")
          |> Enum.drop(1)
        end)
    end
  end
end
