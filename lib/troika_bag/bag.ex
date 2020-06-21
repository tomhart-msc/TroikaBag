defmodule TroikaBag.Bag do
  use GenServer
  require Logger

  @bag_registry_name :bag_process_registry
  @end_token_name "END OF ROUND"

  @doc """
  Starts a new account process for a given `bag_id`.
  """
  def start_link(bag_id) do
    IO.puts("LINK STARTED FOR BAG ID #{inspect bag_id}")
    GenServer.start_link(__MODULE__, bag_id, name: via_tuple(bag_id))
  end

  def fill(pid, stuff) when is_binary(stuff) do
    tokens = String.split(stuff, " ")
    GenServer.cast(pid, {:fill, Enum.flat_map(tokens, fn x -> dups(x) end)})
  end

  def next(pid) do
    GenServer.call(pid, :next)
  end

  @impl true
  def handle_call(:next, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_call(:next, _from, []) do
    {:reply, "empty", []}
  end

  @impl true
  def handle_cast({:fill, elements}, _) do
    {:noreply, Enum.shuffle([@end_token_name | elements])}
  end

  defp dups(token) do
    [name, number] = String.split(token, ":")
    {n, _} = Integer.parse(number)
    for _ <- 1..n, do: name
  end

  # registry lookup handler
  defp via_tuple(bag_id), do: {:via, Registry, {@bag_registry_name, bag_id}}

  @doc """
  Init callback
  Reminder: init is like a constructor which returns {:ok, initial_state}
  """
  @impl true
  def init(bag_id) do
    Logger.info("Process created for bag #{bag_id}")

    # Set initial state and return from `init`
    {:ok, [@end_token_name]}
  end

end
