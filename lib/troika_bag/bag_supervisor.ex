defmodule TroikaBag.BagSupervisor do
  use DynamicSupervisor
  require Logger

  @bag_registry_name :bag_process_registry

  @doc """
  Starts the supervisor.
  """
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: __MODULE__)
  end

  # Returns the pid of the bag for the given ID, or an error
  def bag(bag_id) do
    if bag_process_exists?(bag_id) do
      [{pid, _}] = Registry.lookup(@bag_registry_name, bag_id)
      {:ok, pid}
    else
      bag_id |> create_bag_process
    end
  end

  def bag_process_exists?(bag_id) do
    case Registry.lookup(@bag_registry_name, bag_id) do
      [] -> false
      _ -> true
    end
  end

  def create_bag_process(bag_id) do
    Logger.info("Creating bag #{bag_id}")
    case DynamicSupervisor.start_child(__MODULE__, {TroikaBag.Bag, bag_id}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      other -> {:error, other}
    end
  end

  @impl true
  def init(:no_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
