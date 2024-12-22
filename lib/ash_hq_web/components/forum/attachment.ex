defmodule AshHqWeb.Components.Forum.Attachment do
  @moduledoc "Renders an attachment"
  use Phoenix.Component

  attr(:attachment, :any, required: true)

  def attachment(assigns) do
    ~H"""
    <div>
      <%= case video_type(@attachment.filename) do %>
        <% {:video, mime} -> %>
          <video controls width={@attachment.width} height={@attachment.height}>
            <source src={@attachment.url} type={mime} />
          </video>
        <% {:image, _mime} -> %>
          <img src={@attachment.url} width={@attachment.width} height={@attachment.height} />
        <% _ -> %>
      <% end %>
    </div>
    """
  end

  defp video_type(path) do
    mime = MIME.from_path(path)

    case mime do
      "image/" <> _ ->
        {:image, mime}

      "video/" <> _ ->
        {:video, mime}

      _ ->
        {:other, mime}
    end
  end
end
