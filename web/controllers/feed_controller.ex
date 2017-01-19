defmodule Changelog.FeedController do
  use Changelog.Web, :controller

  alias Changelog.{Episode, Podcast, Post}

  require Logger

  def all(conn, _params) do
    episodes =
      Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_podcast

    posts =
      Post.published
      |> Post.newest_first
      |> Repo.all
      |> Post.preload_author

    items = (episodes ++ posts)
      |> Enum.sort(&(Timex.to_erl(&1.published_at) > Timex.to_erl(&2.published_at)))
      |> Enum.take(50)

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("all.xml", items: items)
  end

  def podcast(conn, %{"slug" => slug}) do
    podcast = Podcast.get_by_slug(slug)

    episodes =
      Podcast.get_episodes(podcast)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_all

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("podcast.xml", podcast: podcast, episodes: episodes)
  end

  def posts(conn, _params) do
    posts =
      Post.published
      |> Post.newest_first
      |> Post.limit(100)
      |> Repo.all
      |> Post.preload_author

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("posts.xml", posts: posts)
  end

  def sitemap(conn, _params) do
    episodes =
      Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_podcast

    posts =
      Post.published
      |> Post.newest_first
      |> Repo.all

    conn
    |> put_layout(false)
    |> render("sitemap.xml", episodes: episodes, posts: posts)
  end
end
