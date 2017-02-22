defmodule Rumbl.TestHelpers do
  alias Rumbl.Repo

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
          name: "Some User",
          username: "user#{Base.encode16(:crypto.rand_bytes(8))}",
          password: "supersecret"},
    attrs)

    %Rumbl.User{}
    |> Rumbl.User.registration_changeset(changes)
    |> Repo.insert!
  end

  def insert_video(user, attrs \\ %{}) do
    # Here we are not using a changeset because nothing
    # in the database prevents us to insert invalid data.
    # So we want to be able to do that in test.
    #
    # In the inser_user we are using a changeset, to fill
    # the :password_hash field

    user
    |> Ecto.build_assoc(:videos, attrs)
    |> Repo.insert!()
  end

end
