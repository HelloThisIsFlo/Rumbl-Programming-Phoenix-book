defmodule Rumbl.Auth do
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

end
