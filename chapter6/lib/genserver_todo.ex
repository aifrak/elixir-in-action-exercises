defmodule GenServerTodo do
  use GenServer

  @impl GenServer
  def init(_) do
    {:ok, TodoList.new()}
  end

  def start() do
    GenServer.start(GenServerTodo, nil)
  end

  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def update_entry(pid, entry) do
    GenServer.cast(pid, {:update_entry, entry})
  end

  @spec delete_entry(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  @spec entries(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, new_entry)}
  end

  def handle_cast({:update_entry, entry}, todo_list) do
    {:noreply, TodoList.update_entry(todo_list, entry)}
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, entry_id)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, todo_list) do
    {:reply, TodoList.entries(todo_list, date), todo_list}
  end
end
