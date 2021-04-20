defmodule SimpleRegistry do
  use GenServer

  @registry_name :registry

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)

    :ok
  end

  def register(term) do
    # According to the solution from the book, this line is necessary
    # see: https://github.com/sasa1977/elixir-in-action/blob/master/code_samples/ch10/process_registry/ets.ex
    #
    # But it also fixes a bug when the process is not deleted properly when a process stops.
    # This line means "link the caller process to the SimpleRegistry process". With the GenServer
    # solution, we were "linking the SimpleRegistry process to caller" by passing the pid with
    # self().
    Process.link(Process.whereis(__MODULE__))

    case :ets.insert_new(@registry_name, {term, self()}) do
      true -> :ok
      false -> :error
    end
  end

  def whereis(term) do
    case :ets.lookup(@registry_name, term) do
      [{_term, pid}] -> pid
      [] -> nil
    end
  end

  @impl GenServer
  def init(_) do
    Process.flag(:trap_exit, true)

    :ets.new(@registry_name, [:named_table, :set, :public])

    {:ok, nil}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, state) do
    :ets.match_delete(@registry_name, {:_, pid})

    {:noreply, state}
  end
end
