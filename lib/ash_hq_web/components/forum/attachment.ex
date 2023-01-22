defmodule AshHqWeb.Components.Forum.Attachment do
  @moduledoc "Renders an attachment"
  use Surface.Component

  prop(attachment, :any, required: true)

  def render(assigns) do
    ~F"""
    <div>
      {#case video_type(@attachment.filename)}
        {#match {:video, mime}}
          <video controls width={@attachment.width} height={@attachment.height}>
            <source src={@attachment.url} type={mime}>
          </video>

        {#match {:image, mime}}
          <img src={@attachment.url} width={@attachment.width} height={@attachment.height} />

        {#match _}
          other
      {/case}
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
