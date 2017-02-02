defmodule Rumbl.User do
  use Rumbl.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true #Virtual means not persisted to the database
    field :password_hash, :string

    timestamps
  end

  def changeset(user, params \\ :invalid) do # passing emtpy deprecated, pass %{} or :invalid
    user
    |> cast(params, [:name, :username])
    |> validate_required([:name])
    |> validate_length(:username, min: 3, max: 20)
  end
end
