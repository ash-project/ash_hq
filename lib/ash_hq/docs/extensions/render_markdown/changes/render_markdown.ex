defmodule AshHq.Docs.Extensions.RenderMarkdown.Changes.RenderMarkdown do
  use Ash.Resource.Change

  def change(changeset, opts, _) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      if Ash.Changeset.changing_attribute?(changeset, opts[:source]) do
        source = Ash.Changeset.get_attribute(changeset, opts[:source])

        case Earmark.as_html(source) do
          {:error, _, error_messages} ->
            Ash.Changeset.add_error(
              changeset,
              Ash.Error.Changes.InvalidAttribute.exception(
                field: :source,
                message: "Could not be transformed into html: #{inspect(error_messages)}"
              )
            )

          {:ok, html_doc, _} ->
            Ash.Changeset.force_change_attribute(changeset, opts[:destination], html_doc)
        end
      else
        changeset
      end
    end)
  end
end
