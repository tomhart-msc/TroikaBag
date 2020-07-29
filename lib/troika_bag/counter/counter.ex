defmodule TroikaBag.Counter.Counter do
  use GenServer
  require Logger

  @counter_registry_name :counter_process_registry

  ############################################################################
  #
  # Client Interface
  #
  ############################################################################

  def get(counter) do
    case counter_process(counter) do
      {:ok, pid} ->
        GenServer.call(pid, :get)
      {:error, _} ->
        "Counter #{counter} does not exist"
    end
  end

  def set(counter, value) when is_integer(value) do
    case counter_process(counter) do
      {:ok, pid} ->
        GenServer.call(pid, {:set, value})
      {:error, _} ->
        "Counter #{counter} does not exist"
    end
  end

  def add(counter, value) when is_integer(value) do
    case counter_process(counter) do
      {:ok, pid} ->
        GenServer.call(pid, {:add, value})
      {:error, _} ->
        "Counter #{counter} does not exist"
    end
  end

  def subtract(counter, value) when is_integer(value) do
    add(counter, value * -1)
  end

  ############################################################################
  #
  # GenServer Implementation
  #
  ############################################################################

  @doc """
  Starts a new account process for a given `counter`.
  """
  def start_link(counter) do
    Logger.info("Process started for counter #{inspect counter}")
    GenServer.start_link(__MODULE__, counter, name: via_tuple(counter))
  end

  @impl true
  def handle_call(:get, _from, n) do
    {:reply, n, n}
  end

  @impl true
  def handle_call({:add, m}, _from, n) do
    {:reply, m + n, m + n}
  end

  @impl true
  def handle_call({:set, m}, _from, _) do
    {:reply, m, m}
  end

  @doc """
  Init callback
  Reminder: init is like a constructor which returns {:ok, initial_state}
  """
  @impl true
  def init(counter) do
    Logger.info("Process created for counter #{counter}")

    # Set initial state and return from `init`
    {:ok, 0}
  end

  ############################################################################
  #
  # Private helpers
  #
  ############################################################################

  defp counter_process(bag_id) do
    case Registry.lookup(@counter_registry_name, bag_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :no_process}
    end
  end

  # registry lookup handler
  defp via_tuple(bag_id), do: {:via, Registry, {@counter_registry_name, bag_id}}

end
