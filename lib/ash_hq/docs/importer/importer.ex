defmodule AshHq.Docs.Importer do
  @moduledoc """
  Builds the documentation into term files in the `priv/docs` directory.
  """

  def import() do
    AshOban.schedule_and_run_triggers(AshHq.Docs.Library)
  end
end
