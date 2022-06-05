defmodule AshHqWeb.ImportController do
  use AshHqWeb, :controller

  def import(conn, %{"library" => library}) do
    send_resp(conn, :ok, "")
    AshHq.Docs.Importer.import(only: library)
  end
end
