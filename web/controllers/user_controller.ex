defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  alias Rumbl.User

  plug :authenticate when action in [:index, :show]

  def index(conn, _opts) do
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
    %User{}
    |> User.registration_changeset(user_params)
    |> Repo.insert
    |> on_user_created(conn)
  end
  defp on_user_created({:error, changeset}, conn) do
    render(conn, "new.html", changeset: changeset)
  end
  defp on_user_created({:ok, user}, conn) do
    conn
    |> Rumbl.Auth.login(user)
    |> put_flash(:info, "#{user.name} created!")
    |> redirect(to: user_path(conn, :index))
  end


  defp authenticate(conn, opts) do
    do_authenticate(conn, conn.assigns.current_user)
  end
  defp do_authenticate(conn, nil) do
    conn
    |> put_flash(:error, "You must be logged in to access that page")
    |> redirect(to: page_path(conn, :index))
    |> halt() # This prevents further plugs downstream to be invoked !
  end
  defp do_authenticate(conn, _current_user), do: conn

end
