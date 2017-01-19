defmodule Changelog.Admin.PersonControllerTest do
  use Changelog.ConnCase
  alias Changelog.Person

  @valid_attrs %{name: "Joe Blow", email: "joe@blow.com", handle: "joeblow"}
  @invalid_attrs %{name: "", email: "noname@nope.com"}

  @tag :as_admin
  test "lists all people on index", %{conn: conn} do
    p1 = insert(:person)
    p2 = insert(:person)

    conn = get(conn, admin_person_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/People/
    assert String.contains?(conn.resp_body, p1.name)
    assert String.contains?(conn.resp_body, p2.name)
  end

  @tag :as_admin
  test "renders form to create new person", %{conn: conn} do
    conn = get(conn, admin_person_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates person and smart redirects", %{conn: conn} do
    conn = post(conn, admin_person_path(conn, :create), person: @valid_attrs, close: true)

    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Person)
    conn = post(conn, admin_person_path(conn, :create), person: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Person) == count_before
  end

  @tag :as_admin
  test "renders form to edit person", %{conn: conn} do
    person = insert(:person)

    conn = get(conn, admin_person_path(conn, :edit, person))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates person and smart redirects", %{conn: conn} do
    person = insert(:person)

    conn = put conn, admin_person_path(conn, :update, person.id), person: @valid_attrs

    assert redirected_to(conn) == admin_person_path(conn, :edit, person)
    assert count(Person) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    person = insert(:person)
    count_before = count(Person)

    conn = put conn, admin_person_path(conn, :update, person.id), person: @invalid_attrs

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Person) == count_before
  end

  @tag :as_admin
  test "deletes a person and redirects", %{conn: conn} do
    person = insert(:person)

    conn = delete conn, admin_person_path(conn, :delete, person.id)

    assert redirected_to(conn) == admin_person_path(conn, :index)
    assert count(Person) == 0
  end

  test "requires user auth on all actions" do
    Enum.each([
      get(build_conn(), admin_person_path(build_conn(), :index)),
      get(build_conn(), admin_person_path(build_conn(), :new)),
      post(build_conn(), admin_person_path(build_conn(), :create), person: @valid_attrs),
      get(build_conn(), admin_person_path(build_conn(), :edit, "123")),
      put(build_conn(), admin_person_path(build_conn(), :update, "123"), person: @valid_attrs),
      delete(build_conn(), admin_person_path(build_conn(), :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
