defmodule WatcherWeb.BasicAuthPlugTest do
  use WatcherWeb.ConnCase, async: true

  alias WatcherWeb.BasicAuthPlug

  @valid_username Application.compile_env(:watcher, :basic_auth)[:username]
  @valid_password Application.compile_env(:watcher, :basic_auth)[:password]

  describe "with basic_auth enabled" do
    test "no credentials return unauthorized", %{conn: conn} do
      conn =
        conn
        |> BasicAuthPlug.basic_auth()

      assert conn.status == 401
    end

    test "invalid credentials return unauthorized", %{conn: conn} do
      conn =
        conn
        |> put_req_header(
          "authorization",
          Plug.BasicAuth.encode_basic_auth("invalid_user", "invalid_password")
        )
        |> BasicAuthPlug.basic_auth()

      assert conn.status == 401
    end

    test "valid credentials do not return unauthorized", %{conn: conn} do
      conn =
        conn
        |> put_req_header(
          "authorization",
          Plug.BasicAuth.encode_basic_auth(@valid_username, @valid_password)
        )
        |> BasicAuthPlug.basic_auth()

      assert conn.status != 401
    end
  end

  describe "with basic_auth disabled" do
    test "no credentials do not return unauthorized", %{conn: conn} do
      conn =
        conn
        |> BasicAuthPlug.basic_auth(should_bypass: true)

      assert conn.status != 401
    end

    test "invalid credentials do not return unauthorized", %{conn: conn} do
      conn =
        conn
        |> put_req_header(
          "authorization",
          Plug.BasicAuth.encode_basic_auth("invalid_username", "invalid_password")
        )
        |> BasicAuthPlug.basic_auth(should_bypass: true)

      assert conn.status != 401
    end

    test "valid credentials do not return unauthorized", %{conn: conn} do
      conn =
        conn
        |> put_req_header(
          "authorization",
          Plug.BasicAuth.encode_basic_auth(@valid_username, @valid_password)
        )
        |> BasicAuthPlug.basic_auth(should_bypass: true)

      assert conn.status != 401
    end
  end
end
