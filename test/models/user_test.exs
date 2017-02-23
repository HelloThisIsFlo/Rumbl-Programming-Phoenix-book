defmodule Rumbl.UserTest do
  use Rumbl.ModelCase, async: true
  alias Rumbl.User

  @valid_attrs %{name: "A User", username: "eva2000", password: "secret"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset does not accept long usernames" do
    attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))

    assert {:username, "should be at most 20 character(s)"} in errors_on(%User{}, attrs)

  end

  test "registration_changeset password must be at least 6 chars long" do
    attrs = Map.put(@valid_attrs, :password, "12345")
    changeset = User.registration_changeset(%User{}, attrs)

    errors =
      changeset
      |> Ecto.Changeset.traverse_errors(&Rumbl.ErrorHelpers.translate_error/1)
      |> Enum.flat_map(fn {key, errors} -> for msg <- errors, do: {key, msg} end)

    assert {:password, "should be at least 6 character(s)"} in errors
  end

  test "registration_changeset with valid attributes hashes password" do
    attrs = Map.put(@valid_attrs, :password, "123456")
    changeset = User.registration_changeset(%User{}, attrs)

    assert changeset.valid?
    assert Map.has_key?(changeset.changes, :password_hash)

    pass_hash = Map.fetch!(changeset.changes, :password_hash)
    assert Comeonin.Bcrypt.checkpw("123456", pass_hash)
  end



  #############################################################################
  #                        My tests (not from the book)                       #
  #############################################################################
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
