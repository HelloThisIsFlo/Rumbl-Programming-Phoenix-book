defmodule Rumbl.CategoryRepoTest do
  use Rumbl.ModelCase
  alias Rumbl.Category

  test "alphabetically/1 orders by name" do
    Repo.insert!(%Category{name: "c"})
    Repo.insert!(%Category{name: "a"})
    Repo.insert!(%Category{name: "b"})

    query =
      Category
      |> Category.alphabetically
      |> get_only_name

    assert Repo.all(query) == ~w(a b c)
  end

  defp get_only_name(query), do: from c in query, select: c.name


end
