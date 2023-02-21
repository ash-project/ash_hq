defmodule AshHqWeb.DslRedirectController do
  use AshHqWeb, :controller

  def show(conn, %{"library" => library, "extension" => extension_name, "dsl_path" => dsl_path}) do
    library = AshHq.Docs.Library.by_name!(library, load: [latest_library_version: :extensions])

    extension =
      library.latest_library_version.extensions
      |> Enum.find(fn extension ->
        AshHqWeb.DocRoutes.sanitize_name(extension.name) == extension_name
      end)
      |> Kernel.||(raise Ash.Error.Query.NotFound)

    target = AshHqWeb.DocRoutes.sanitize_name(extension.target)

    redirect(conn, to: "/docs/dsl/#{target}##{Enum.join(dsl_path, "-")}")
  end
end
