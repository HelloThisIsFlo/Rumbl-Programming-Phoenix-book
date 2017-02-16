defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  alias Rumbl.User

  plug :authenticate_user when action in [:index, :show]

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

end
