defmodule PollsApplicationWeb.PollLiveTest do
  use PollsApplicationWeb.ConnCase

  import Phoenix.LiveViewTest
  import PollsApplication.PollsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_poll(_) do
    poll = poll_fixture()
    %{poll: poll}
  end

  describe "Index" do
    setup [:create_poll]

    test "lists all poll", %{conn: conn, poll: poll} do
      {:ok, _index_live, html} = live(conn, ~p"/poll")

      assert html =~ "Listing Poll"
      assert html =~ poll.name
    end

    test "saves new poll", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/poll")

      assert index_live |> element("a", "New Poll") |> render_click() =~
               "New Poll"

      assert_patch(index_live, ~p"/poll/new")

      assert index_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#poll-form", poll: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/poll")

      html = render(index_live)
      assert html =~ "Poll created successfully"
      assert html =~ "some name"
    end

    test "updates poll in listing", %{conn: conn, poll: poll} do
      {:ok, index_live, _html} = live(conn, ~p"/poll")

      assert index_live |> element("#poll-#{poll.id} a", "Edit") |> render_click() =~
               "Edit Poll"

      assert_patch(index_live, ~p"/poll/#{poll}/edit")

      assert index_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#poll-form", poll: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/poll")

      html = render(index_live)
      assert html =~ "Poll updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes poll in listing", %{conn: conn, poll: poll} do
      {:ok, index_live, _html} = live(conn, ~p"/poll")

      assert index_live |> element("#poll-#{poll.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#poll-#{poll.id}")
    end
  end

  describe "Show" do
    setup [:create_poll]

    test "displays poll", %{conn: conn, poll: poll} do
      {:ok, _show_live, html} = live(conn, ~p"/poll/#{poll}")

      assert html =~ "Show Poll"
      assert html =~ poll.name
    end

    test "updates poll within modal", %{conn: conn, poll: poll} do
      {:ok, show_live, _html} = live(conn, ~p"/poll/#{poll}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Poll"

      assert_patch(show_live, ~p"/poll/#{poll}/show/edit")

      assert show_live
             |> form("#poll-form", poll: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#poll-form", poll: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/poll/#{poll}")

      html = render(show_live)
      assert html =~ "Poll updated successfully"
      assert html =~ "some updated name"
    end
  end
end
