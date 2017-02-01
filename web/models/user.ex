defmodule Rumbl.User do
  use Rumbl.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true #Virtual means not persisted to the database
    field :password_hash, :string

    timestamps
  end
end
