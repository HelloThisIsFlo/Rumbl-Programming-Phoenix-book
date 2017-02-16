defmodule Rumbl.Auth do
  alias Rumbl.User
  alias Comeonin.Bcrypt
  import Plug.Conn

  def init(opts) do
    # Check that the repo is provided, crash if not
    # And store in in the "state"
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    # This means: If left value not null => Get right value
    user    = user_id && repo.get(Rumbl.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(User, username: username)

    cond do
      user && Bcrypt.checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        fake_hash()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    conn
    |> configure_session(drop: true)
  end

  # Make a hash with a random password.
  # This prevents an attacker to guess usernames by timing the responses
  # Even if the username is not found, some time will still be spent to
  # hash a fake password
  defp fake_hash, do: Bcrypt.dummy_checkpw()


end
