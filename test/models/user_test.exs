defmodule Rumbl.UserTest do
  use Rumbl.ModelCase
  alias Rumbl.User

  test "no name => invalid changeset" do
    user = %User{name: "patrick"}
    no_name = %User{}

    invalid1 = User.changeset(user, %{name: ""})
    invalid2 = User.changeset(user, %{name: ""})
    invalid3 = User.changeset(no_name, %{})

    valid1 = User.changeset(user, %{name: "not empty"})
    valid2 = User.changeset(no_name, %{name: "not empty"})
    valid3 = User.changeset(user, %{})


    refute invalid1.valid?, inspect(invalid1)
    refute invalid2.valid?, inspect(invalid2)
    refute invalid3.valid?, inspect(invalid3)

    assert valid1.valid?, inspect(valid1)
    assert valid2.valid?, inspect(valid2)
    assert valid3.valid?, inspect(valid3)
  end

  test "username less than 3 char => invalid changeset" do
    user = %User{name: "patrick", username: "hello2324"}
    no_username = %User{name: "patrick"}

    invalid1 = User.changeset(user, %{username: "b"}) # less than 3 char
    invalid2 = User.changeset(user, %{username: "ab"}) # less than 3 char

    valid1 = User.changeset(user, %{username: "abc"})
    valid2 = User.changeset(no_username, %{})
    valid3 = User.changeset(user, %{username: nil}) # nil removes username => fine since not required
    valid4 = User.changeset(user, %{username: ""}) # emtpy is like nil

    refute invalid1.valid?, inspect(invalid1)
    refute invalid2.valid?, inspect(invalid2)

    assert valid1.valid?, inspect(valid1)
    assert valid2.valid?, inspect(valid2)
    assert valid3.valid?, inspect(valid3)
    assert valid4.valid?, inspect(valid4)
  end

end
