defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  alias Rumbl.User

  def index(conn, _params) do
    conn
    |> authenticate
    |> do_index
  end
  defp do_index(%Plug.Conn{halted: true} = conn), do: conn
  defp do_index(conn) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get_by(User, %{id: id})
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp authenticate(conn) do
    do_authenticate(conn, conn.assigns.current_user)
  end
  defp do_authenticate(conn, nil) do
    conn
    |> put_flash(:error, "You must be logged in to access that page")
    |> redirect(to: page_path(conn, :index))
    |> halt()
  end
  defp do_authenticate(conn, _current_user), do: conn

end
