defmodule TodoList.CsvImporter do
  @column_index %{date: 0, title: 1}
  @column_separator ","

  def import(path) do
    path
    |> read_rows!()
    |> create_entries()
    |> TodoList.new()
  end

  defp read_rows!(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp create_entries(rows) do
    rows
    |> Stream.map(&read_cells!(&1))
    |> Stream.filter(&valid_entry?(&1))
  end

  defp valid_entry?(%{date: _, title: _}), do: true
  defp valid_entry?(_), do: false

  defp read_cells!(row) do
    row
    |> String.split(@column_separator)
    |> create_entry()
  end

  defp create_entry(cells) do
    with {:ok, date_str} <- Enum.fetch(cells, @column_index.date),
         {:ok, title} <- Enum.fetch(cells, @column_index.title),
         {:ok, date} <- parse_date(date_str) do
      %{date: date, title: title}
    end
  end

  defp parse_date(cell) do
    cell
    |> String.replace("/", "-")
    |> Date.from_iso8601()
  end
end
