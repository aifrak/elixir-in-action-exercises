defmodule Recursion do
  @doc """
  Calculates the length of a list.
  """
  @spec list_len(list) :: integer
  def list_len(list) do
    do_list_len(list, 0)
  end

  defp do_list_len([], acc), do: acc

  defp do_list_len([_ | tail], acc) do
    do_list_len(tail, acc + 1)
  end

  @doc """
  Returns a list of all numbers in the given range.
  """
  @spec range(integer, integer) :: list(integer)
  def range(from, to) do
    do_range(from, to, [])
  end

  defp do_range(from, to, acc) when from == to, do: [to | acc]

  defp do_range(from, to, acc) when from > to do
    list = [to | acc]
    do_range(from, to + 1, list)
  end

  defp do_range(from, to, acc) do
    list = [to | acc]
    do_range(from, to - 1, list)
  end

  @doc """
  Returns a list containing only positive numbers.
  """
  @spec positive(list) :: list(integer)
  def positive(list) do
    do_positive(list, [])
    |> Enum.reverse()
  end

  defp do_positive([], acc), do: acc

  defp do_positive([head | tail], acc) when head > 0 do
    do_positive(tail, [head | acc])
  end

  defp do_positive([_ | tail], acc) do
    do_positive(tail, acc)
  end
end
