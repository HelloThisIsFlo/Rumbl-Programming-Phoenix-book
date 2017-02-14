defmodule Rumbl.UserTest do
  use Rumbl.ModelCase
  alias Rumbl.User

  test "no name => invalid changeset" do
    user = %User{name: "patrick", username: "patou223"}
    no_name = %User{username: "patou223"}

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
    invalid3 = User.changeset(no_username, %{})
    invalid4 = User.changeset(user, %{username: nil}) # nil removes username => Not fine since required
    invalid5 = User.changeset(user, %{username: ""}) # emtpy is like nil

    valid1 = User.changeset(user, %{username: "abc"})

    refute invalid1.valid?, inspect(invalid1)
    refute invalid2.valid?, inspect(invalid2)
    refute invalid3.valid?, inspect(invalid3)
    refute invalid4.valid?, inspect(invalid4)
    refute invalid5.valid?, inspect(invalid5)

    assert valid1.valid?, inspect(valid1)
  end

  test "password is ignored in the changeset" do
    with_password = %User{password: "asd", name: "Frank", username: "Franky234"}

    no_changes = User.changeset(with_password, %{})
    password_change = User.changeset(with_password, %{password: "asdf"})
    username_change = User.changeset(with_password, %{username: "hello123", password: "asdf"})

    assert_password_change_is_ignored no_changes
    assert_password_change_is_ignored password_change
    assert_password_change_is_ignored username_change
    assert Map.has_key? username_change.changes, :username
  end

  def assert_password_change_is_ignored(changeset) do
    refute Map.has_key? changeset.changes, :password
    assert changeset.valid?
  end
end
