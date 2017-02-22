defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase, async: false
  alias Rumbl.Video

  @valid_video_params %{url: "http://youtu.be", title: "vid", description: "a vid"}
  @invalid_video_params %{title: "invalid"}

  setup %{conn: conn} = context do
    if username = context[:login_as] do
      user = insert_user(username: username)
      conn = assign(conn, :current_user, user)
      {:ok, conn: conn, user: user}
    else
      # conn is assigned in TestTemplate
      :ok
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      get(conn, video_path(conn, :update, "123", %{})),
      get(conn, video_path(conn, :create, %{})),
      get(conn, video_path(conn, :delete, "123"))
    ], fn(conn) ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "lists all user's videos on index", %{conn: conn, user: user} do
    user_video = insert_video(user, title: "funny cats")
    other_video = insert_video(insert_user(username: "another_user"), title: "another video")

    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  @tag login_as: "max"
  test "create a video, and show it on show/index", %{conn: conn, user: user} do
    params = %{
      url: "http://hello",
      title: "title",
      description: "description"
    }

    post conn, video_path(conn, :create), video: params

    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ "http://hello"
  end

  @tag login_as: "max"
  test "creates user video and redirects", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_video_params
    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_video_params).user_id == user.id
  end

  @tag login_as: "max"
  test "does not cresate video and renders errors when invalid", %{conn: conn} do
    # Given: No video stored
    assert video_count(Video) == 0

    # When: Adding invalid video
    conn = post conn, video_path(conn, :create), video: @invalid_video_params

    # Then: Error is displayed and video is not saved
    assert html_response(conn, 200) =~ "check the errors"
    assert video_count(Video) == 0
  end

  @tag login_as: "max"
  test "authorizes actions against access by other users", %{user: owner, conn: conn} do
    video = insert_video(owner, @valid_video_params)
    non_owner = insert_user(username: "sneaky")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :show, video))
    end
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :edit, video))
    end
    assert_error_sent :not_found, fn ->
      put(conn, video_path(conn, :update, video), video: @valid_video_params)
    end
    assert_error_sent :not_found, fn ->
      get(conn, video_path(conn, :delete, video))
    end
  end

  defp video_count(query), do: Repo.one(from v in query, select: count(v.id))

end
