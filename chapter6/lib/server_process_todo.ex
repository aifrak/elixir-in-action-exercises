defmodule ServerProcessTodo do
  def start() do
    ServerProcess.start(ServerProcessTodo)
  end

  def add_entry(pid, new_entry) do
    ServerProcess.cast(pid, {:add_entry, new_entry})
  end

  def update_entry(pid, entry) do
    ServerProcess.cast(pid, {:update_entry, entry})
  end

  def delete_entry(pid, entry_id) do
    ServerProcess.cast(pid, {:delete_entry, entry_id})
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  def init(), do: %TodoList{}

  def handle_cast({:add_entry, new_entry}, todo_list) do
    TodoList.add_entry(todo_list, new_entry)
  end

  def handle_cast({:update_entry, entry}, todo_list) do
    TodoList.update_entry(todo_list, entry)
  end

  def handle_cast({:delete_entry, entry_id}, todo_list) do
    TodoList.delete_entry(todo_list, entry_id)
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
  end
end
