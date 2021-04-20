defmodule TodoServer do
  def start do
    spawn(fn -> loop(TodoList.new()) end)
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def update_entry(todo_server, entry) do
    send(todo_server, {:update_entry, entry})
  end

  def delete_entry(todo_server, entry_id) do
    send(todo_server, {:delete_entry, entry_id})
  end

  @spec entries(atom | pid | port | {atom, atom}, any) :: any
  def entries(todo_server, date) do
    send(todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:update_entry, entry}) do
    TodoList.update_entry(todo_list, entry)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, _), do: todo_list
end
