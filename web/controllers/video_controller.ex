defmodule Rumbl.VideoController do
  use Rumbl.Web, :controller
  alias Rumbl.Video
  alias Rumbl.Category
  require Logger

  plug :load_categories_in_template when action in [:new, :create, :edit, :update]

  # Override action function ##################################################
  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn,
                                          conn.params,
                                          conn.assigns.current_user])
  end

  # Function Plug #############################################################
  def load_categories_in_template(conn, _) do
    Logger.debug "Loading video categories in template"
    categories =
      Category
      |> Category.names_and_ids_tuple
      |> Category.alphabetically
      |> Repo.all
    assign(conn, :categories, categories)
  end


  #############################################################################
  #                                 Controller                                #
  #############################################################################
  def index(conn, _params, user) do
    videos = Repo.all(user_videos_query(user))
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, user) do
    # We don't really need to put the user in this changeset at this point (new), but ok.
    # Allows to display a already-filled user_id on the form. (not used)
    # Still keep it here to be 1-to-1 with the Phoenix Book
    changeset =
      user
      |> build_assoc(:videos)
      |> Video.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do
    changeset =
      user
      |> build_assoc(:videos)
      |> Video.changeset(video_params)

    case Repo.insert(changeset) do
      {:ok, _video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: video_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos_query(user), id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos_query(user), id)
    changeset = Video.changeset(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    video = Repo.get!(user_videos_query(user), id)
    changeset = Video.changeset(video, video_params)

    case Repo.update(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: video_path(conn, :show, video))
      {:error, changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    video = Repo.get!(user_videos_query(user), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: video_path(conn, :index))
  end

  defp user_videos_query(user) do
    assoc(user, :videos)
  end

end
