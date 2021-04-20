defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_folder)

    workers = create_workers()

    {:ok, workers}
  end

  defp create_workers() do
    Stream.map(0..2, &create_worker/1)
    |> Enum.into(%{})
  end

  defp create_worker(worker_id) do
    {:ok, worker} = Todo.DatabaseWorker.start(@db_folder)

    {worker_id, worker}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, workers) do
    workers
    |> choose_worker(key)
    |> Todo.DatabaseWorker.store(key, data)

    {:noreply, workers}
  end

  @impl GenServer
  def handle_call({:get, key}, _, workers) do
    data =
      workers
      |> choose_worker(key)
      |> Todo.DatabaseWorker.get(key)

    {:reply, data, workers}
  end

  defp choose_worker(workers, index) do
    workers
    |> Map.get(:erlang.phash2(index, 3))
  end
end
