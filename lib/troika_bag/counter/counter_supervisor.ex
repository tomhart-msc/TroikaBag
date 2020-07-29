defmodule TroikaBag.Counter.CounterSupervisor do
  use DynamicSupervisor
  require Logger

  @counter_registry_name :counter_process_registry

  @doc """
  Starts the supervisor.
  """
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  # Returns the pid of the counter for the given variable, or an error
  def counter(var) do
    if counter_process_exists?(var) do
      {:ok, var}
    else
      var |> create_counter_process
    end
  end

  def counter_process_exists?(var) do
    case Registry.lookup(@counter_registry_name, var) do
      [] -> false
      _ -> true
    end
  end

  def create_counter_process(var) do
    Logger.info("Creating counter #{var}")
    case DynamicSupervisor.start_child(__MODULE__, {TroikaBag.Counter.Counter, var}) do
      {:ok, _pid} -> {:ok, var}
      {:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      other -> {:error, other}
    end
  end

  @impl true
  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
