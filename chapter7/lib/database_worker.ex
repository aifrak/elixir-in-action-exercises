defmodule Todo.DatabaseWorker do
  use GenServer

  def start(folder_path) do
    GenServer.start(__MODULE__, folder_path)
  end

  def store(server, key, data) do
    GenServer.cast(server, {:store, key, data})
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  @impl GenServer
  def init(folder_path) do
    {:ok, folder_path}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, folder_path) do
    key
    |> file_name(folder_path)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, folder_path}
  end

  @impl GenServer
  def handle_call({:get, key}, _, folder_path) do
    data =
      case File.read(file_name(key, folder_path)) do
        {:ok, contents} -> :erlang.binary_to_term(contents)
        _ -> nil
      end

    {:reply, data, folder_path}
  end

  defp file_name(key, folder_path) do
    Path.join(folder_path, to_string(key))
  end
end
