defmodule ReadLine do
  @doc """
  Returns a list of numbers, with each number representing the length of the corresponding line
  from the file.
  """
  @spec lines_lengths!(String.t()) :: list(integer)
  def lines_lengths!(path) do
    read_lines!(path)
    |> Enum.map(&String.length(&1))
  end

  @doc """
  Returns the length of the longest line in a file.
  """
  @spec longest_line_length!(String.t()) :: integer
  def longest_line_length!(path) do
    read_lines!(path)
    |> Stream.map(&String.length(&1))
    |> Enum.max()
  end

  @doc """
  Returns the contents of the longest line in a file.
  """
  @spec longest_line!(String.t()) :: String.t()
  def longest_line!(path) do
    read_lines!(path)
    |> Enum.max_by(&String.length(&1))
  end

  @doc """
  Returns a list of numbers, with each number representing the word count in a file.
  """
  @spec words_per_line!(String.t()) :: list(integer)
  def words_per_line!(path) do
    read_lines!(path)
    |> Enum.map(&(String.split(&1) |> length()))
  end

  defp read_lines!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
  end
end
