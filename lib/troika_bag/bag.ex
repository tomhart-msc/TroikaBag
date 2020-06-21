defmodule TroikaBag.Bag do
  use GenServer
  require Logger

  @bag_registry_name :bag_process_registry
  @end_token_name "END OF ROUND"

  ############################################################################
  #
  # Client Interface
  #
  ############################################################################

  def fill(bag_id, stuff) when is_binary(stuff) do
    case bag_process(bag_id) do
      {:ok, pid} ->
        tokens = String.split(stuff, " ")
        GenServer.cast(pid, {:fill, Enum.flat_map(tokens, fn x -> dups(x) end)})
      {:error, _} ->
        "Bag #{bag_id} does not exist"
    end
  end

  def next(bag_id) do
    case bag_process(bag_id) do
      {:ok, pid} ->
        GenServer.call(pid, :next)
      {:error, _} ->
        "Bag #{bag_id} does not exist"
    end
  end

  ############################################################################
  #
  # GenServer Implementation
  #
  ############################################################################

  @doc """
  Starts a new account process for a given `bag_id`.
  """
  def start_link(bag_id) do
    Logger.info("Process started for bag #{inspect bag_id}")
    GenServer.start_link(__MODULE__, bag_id, name: via_tuple(bag_id))
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

  ############################################################################
  #
  # Private helpers
  #
  ############################################################################

  defp bag_process(bag_id) do
    case Registry.lookup(@bag_registry_name, bag_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :no_process}
    end
  end

  defp dups(token) do
    [name, number] = String.split(token, ":")
    {n, _} = Integer.parse(number)
    for _ <- 1..n, do: name
  end

  # registry lookup handler
  defp via_tuple(bag_id), do: {:via, Registry, {@bag_registry_name, bag_id}}

end
