defmodule TroikaBag.EventListener do
  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  # The only events we care about are message creation events
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cmd = command(msg.content)
    case cmd do
      "!fill" ->
        id = bag_id(msg)
        {:ok, pid} = TroikaBag.BagSupervisor.bag(id)
        TroikaBag.Bag.fill(pid, String.replace(msg.content, "!fill ", ""))
        Api.create_message(msg.channel_id, "Bag has been filled!")
      "!next" ->
        id = bag_id(msg)
        {:ok, pid} = TroikaBag.BagSupervisor.bag(id)
        Api.create_message(msg.channel_id, TroikaBag.Bag.next(pid))
      _ -> :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end

  # Guild is a server, channel is a channel
  # Example ID: 665559199870353451.723462990942175242
  defp bag_id(msg), do: "#{msg.guild_id}.#{msg.channel_id}"

  defp command(str), do: Enum.at(String.split(str, " "), 0, "")
end
