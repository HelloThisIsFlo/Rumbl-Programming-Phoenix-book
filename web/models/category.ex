defmodule Rumbl.Category do
  use Rumbl.Web, :model

  schema "categories" do
    field :name, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  def alphabetically(category_query), do: from c in category_query, order_by: c.name
  def names_and_ids_tuple(category_query), do: from c in category_query, select: {c.name, c.id}
end
