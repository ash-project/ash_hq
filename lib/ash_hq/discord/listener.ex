defmodule AshHq.Discord.Listener do
  use Nostrum.Consumer

  # alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  # Lets set up slash commands later
  # def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
  #   IO.inspect(msg)
  # end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end
end
