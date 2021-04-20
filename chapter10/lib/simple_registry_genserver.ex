defmodule SimpleRegistry.GenServer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(term) do
    GenServer.call(__MODULE__, {:register, term, self()})
  end

  def whereis(term) do
    GenServer.call(__MODULE__, {:whereis, term})
  end

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)

    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:register, term, pid}, _from, processes) do
    case Map.get(processes, term) do
      nil ->
        Process.link(pid)
        {:reply, :ok, Map.put(processes, term, pid)}

      _ ->
        {:reply, :error, processes}
    end
  end

  @impl GenServer
  def handle_call({:whereis, term}, _from, processes) do
    {:reply, Map.get(processes, term), processes}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, processes) do
    {:noreply, remove_process(processes, pid)}
  end

  defp remove_process(processes, pid) do
    processes
    |> Stream.reject(&(has_process(&1, pid)))
    |> Enum.into(%{})
  end

  defp has_process({_term, found_pid}, pid) do
    pid == found_pid
  end
end
