defmodule TroikaBag.EventListener do
  use Nostrum.Consumer
  alias Nostrum.Api
  require Logger

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  # The only events we care about are message creation events
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cmd = command(msg.content)
    case cmd do
      "!fill" ->
        id = bag_id(msg)
        {:ok, _} = TroikaBag.BagSupervisor.bag(id)
        TroikaBag.Bag.fill(id, String.replace(msg.content, "!fill ", ""))
        Api.create_message(msg.channel_id, "Bag has been filled!")
      "!next" ->
        id = bag_id(msg)
        {:ok, _} = TroikaBag.BagSupervisor.bag(id)
        Api.create_message(msg.channel_id, TroikaBag.Bag.next(id))
      "!add" ->
        Logger.info("Told to add")
        case parse_counter_args(msg.content) do
          {:ok, var, num} ->
            Logger.info("Parsed arguments #{var} and #{num}")
            id = counter_id(var, msg)
            {:ok, _} = TroikaBag.Counter.CounterSupervisor.counter(id)
            Api.create_message(msg.channel_id, Integer.to_string(TroikaBag.Counter.Counter.add(id, num)))
          :error -> :ignore
        end
      "!set" ->
        case parse_counter_args(msg.content) do
          {:ok, var, num} ->
            id = counter_id(var, msg)
            {:ok, _} = TroikaBag.Counter.CounterSupervisor.counter(id)
            Api.create_message(msg.channel_id, Integer.to_string(TroikaBag.Counter.Counter.set(id, num)))
          :error -> :ignore
        end
      "!sub" ->
        case parse_counter_args(msg.content) do
          {:ok, var, num} ->
            id = counter_id(var, msg)
            {:ok, _} = TroikaBag.Counter.CounterSupervisor.counter(id)
            Api.create_message(msg.channel_id, Integer.to_string(TroikaBag.Counter.Counter.subtract(id, num)))
          :error -> :ignore
        end
      "!get" ->
        case parse_counter_get(msg.content) do
          {:ok, var} ->
            id = counter_id(var, msg)
            {:ok, _} = TroikaBag.Counter.CounterSupervisor.counter(id)
            Api.create_message(msg.channel_id, Integer.to_string(TroikaBag.Counter.Counter.get(id)))
          :error -> :ignore
        end
      _ -> :ignore
    end
  end

  # Default event handler, if you don't include this, your consumer WILL crash if
  # you don't have a method definition for each event type.
  def handle_event(_event) do
    :noop
  end

  defp parse_counter_args(cmd) do
    args = Regex.named_captures(~r/![[:alpha:]]+\s(?<var>[[:alpha:]]+)\s+(?<num>\d+)/, cmd)
    Logger.info("Parsed args #{inspect args} from #{cmd}")
    counter_args(args)
  end

  defp parse_counter_get(cmd) do
    %{"var" => var} = Regex.named_captures(~r/![[:alpha:]]+\s(?<var>[[:alpha:]]+)/, cmd)
    {:ok, var}
  end

  defp counter_args(%{"num" => num, "var" => var}) do
    {n, _} = Integer.parse(num)
    {:ok, var, n}
  end

  defp counter_args(_), do: :error

  defp counter_id(var, msg), do: var <> "." <> bag_id(msg)

  # Guild is a server, channel is a channel
  # Example ID: 665559199870353451.723462990942175242
  defp bag_id(msg), do: "#{msg.guild_id}.#{msg.channel_id}"

  defp command(str), do: Enum.at(String.split(str, " "), 0, "")
end
