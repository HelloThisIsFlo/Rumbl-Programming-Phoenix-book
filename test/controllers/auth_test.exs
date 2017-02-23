defmodule Rumbl.AuthTest do
  use Rumbl.ConnCase
  alias Rumbl.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Rumbl.Router, :browser) # Doesn't 'do' anything, just put a flag
      |> get("/")

    {:ok, conn: conn}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user continues when the current_user exists", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Rumbl.User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn =
      conn
      |> Auth.login(%Rumbl.User{id: 123})
      # |> configure_session(drop: true) # <-- This would make fail the second assert
      |> send_resp(:ok, "")

    assert get_session(login_conn, :user_id) == 123

    # Check that even after a new connection, :user_id is still available
    # `get` calls the endpoint pipeline, the router and its pipelines, and the controller
    next_conn =
      login_conn
      |> recycle() # Recycle the connection, simulate what browser would do
      |> get("/")

    assert get_session(next_conn, :user_id) == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    next_conn =
      logout_conn
      |> recycle() # Recycle the connection, simulate what browser would do
      |> get("/")

    refute get_session(next_conn, :user_id)
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Repo)

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets :current_user assign to nil", %{conn: conn} do
    conn = conn |> Auth.call(Repo)
    assert conn.assigns.current_user == nil
  end

  test "login with a valid username and pass", %{conn: conn} do
    user = insert_user(username: "me2354", password: "secret")

    {:ok, conn} =
      Auth.login_by_username_and_pass(conn, "me2354", "secret", repo: Repo)

    assert get_session(conn, :user_id) == user.id
    assert conn.assigns.current_user.id == user.id
  end

  test "login with a not found user", %{conn: conn} do
    assert {:error, :not_found, _} =
      Auth.login_by_username_and_pass(conn, "not found", "abc", repo: Repo)
  end

  test "login with password mismatch", %{conn: conn} do
    _ = insert_user(username: "me1234", password: "secret")
    assert {:error, :unauthorized, _} =
    Auth.login_by_username_and_pass(conn, "me1234", "wrong", repo: Repo)
  end

end
